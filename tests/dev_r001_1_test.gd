extends SceneTree

const DATA := preload("res://data/source_mapping/craftpix.json")
const AUDIT := preload("res://data/source_mapping/craftpix_audit.json")
const SPRITE := preload("res://systems/animation/source_sprite.gd")
const HOME := preload("res://scenes/world/home_source.gd")
var checks := 0
var failures := 0
var finish_count := 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func image(path: String) -> Image:
	var result := Image.new()
	check(result.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK, "Original PNG decodes")
	return result

func check_composition(sprite: SourceSprite, layers: Array, full: Dictionary) -> void:
	var expected := image(full.file).get_region(Rect2i(sprite.source_region(full)))
	var composite := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	composite.fill(Color.TRANSPARENT)
	for layer: Dictionary in layers:
		composite.blend_rect(image(layer.file), Rect2i(sprite.source_region(layer)), Vector2i.ZERO)
	var differences := 0
	for y in range(64):
		for x in range(64):
			var a := composite.get_pixel(x, y)
			var b := expected.get_pixel(x, y)
			if absf(a.a - b.a) > 1.01 / 255.0 or (a.a > 0.01 and maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b))) > 1.01 / 255.0):
				differences += 1
	check(differences == 0, "Attack pixels match original full source: %s %d (%d differences)" % [sprite.direction, sprite.frame_index, differences])

func run_tests() -> void:
	for action: String in ["move_left", "move_right", "move_up", "move_down", "run", "attack_primary"]:
		check(InputMap.has_action(action), "Semantic input exists: " + action)
	var bindings := InputMap.action_get_events("attack_primary")
	check(bindings.size() == 2, "Exactly two development attack bindings")
	check(bindings[0] is InputEventKey and bindings[0].physical_keycode == KEY_J, "Physical J attack")
	check(bindings[1] is InputEventMouseButton and bindings[1].button_index == MOUSE_BUTTON_LEFT, "LMB attack")
	check(InputMap.event_is_action(bindings[0], "attack_primary") and InputMap.event_is_action(bindings[1], "attack_primary"), "Both bind the same action")
	var sprite := SPRITE.new()
	root.add_child(sprite)
	sprite.set_process(false)
	sprite.sword = true
	sprite.animation_finished.connect(func(state: String):
		check(state == "attack", "Completion names the state")
		finish_count += 1)
	var attack: Dictionary = sprite.mapping.states.attack
	check(attack.frame_count == 8 and not attack.loop and attack.durations_ms == [150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0, 150.0], "Exact 8x150ms non-loop attack")
	check(sprite.mapping.frame_size == 64 and sprite.mapping.pivot == [32.0, 44.0], "Unchanged human geometry/pivot")
	for layer: Dictionary in attack.sword_layers + [attack.sword_full, attack.sword_full_with_shadow]:
		check(image(layer.file).get_size() == Vector2i(512, 256), "Four rows of eight 64px cells")
		var verified := false
		for tileset: Dictionary in AUDIT.data.source_tmx["main_character/male/Base_boy.tmx"].tilesets:
			if tileset.source == str(layer.file).get_file():
				verified = true
				check(layer.source_columns == tileset.logical_sequences, "Attack uses audited explicit TMX columns/durations")
		check(verified, "Attack layer has original TMX evidence")
	for direction: String in ["down", "left", "right", "up"]:
		sprite.set_pose("attack", direction)
		var before := finish_count
		for step in range(8):
			check(sprite.frame_index == step and not sprite.finished, "All eight frames in order")
			check_composition(sprite, sprite.current_sword_layers(), attack.sword_full)
			check_composition(sprite, [attack.shadow] + sprite.current_sword_layers(), attack.sword_full_with_shadow)
			sprite.advance(0.149)
			check(sprite.frame_index == step and finish_count == before, "Full 150ms hold, including last frame")
			sprite.advance(0.001)
		check(sprite.frame_index == 7 and sprite.finished and finish_count == before + 1, "Last frame never wraps, completion once")
		sprite.advance(10)
		check(sprite.frame_index == 7 and finish_count == before + 1, "No repeated completion")
	sprite.set_pose("idle", "down")
	check(not sprite.finished, "Locomotion clears finished flag")
	sprite.set_pose("attack", "down")
	sprite.advance(3)
	check(sprite.frame_index == 7 and sprite.finished and finish_count == 5, "Large delta completes once without modulo")
	sprite.free()
	var main: Node2D = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var world: Node2D = main.get_node("TestWorld")
	var player := world.get_node("Actors/Player") as PlayerV2
	var boar: CharacterBody2D = world.get_node("Actors/BoarPreview")
	player.set_physics_process(false)
	player.visual.set_process(false)
	boar.set_physics_process(false)
	boar.visual.set_process(false)
	var root_before := player.position
	check(not player.start_attack() and player.visual.state == "idle", "Unarmed attack is no-op")
	player.toggle_sword()
	for state: String in ["idle", "walk", "run"]:
		player.visual.set_pose(state, "left")
		player.toggle_sword()
		check(not player.visual.sword and player.visual.state == state, "Unequip preserves locomotion")
		player.toggle_sword()
		check(player.visual.sword and player.visual.state == state, "Equip preserves locomotion")
	for after: String in ["idle", "walk", "run"]:
		player.visual.set_pose("idle", "down")
		check(player.start_attack(), "Equipped attack starts")
		player.visual.advance(0.45)
		var held_frame := player.visual.frame_index
		check(not player.start_attack() and player.visual.frame_index == held_frame, "Spam cannot restart")
		player.toggle_sword()
		check(player.visual.sword, "Tab ignored during attack")
		if after != "idle":
			Input.action_press("move_right")
		if after == "run":
			Input.action_press("run")
		player._physics_process(1.0 / 60.0)
		check(player.position == root_before and player.velocity == Vector2.ZERO and player.visual.direction == "down", "Attack locks position and facing despite movement input")
		player.visual.advance(0.749)
		check(player.attacking and player.visual.frame_index == 7, "Final frame retained before completion")
		player.visual.advance(0.001)
		check(not player.attacking and player.visual.state == after and player.position == root_before, "Completion returns to current input without moving root")
		check(player.get_node("CollisionShape2D").shape.size == Vector2(10, 6) and player.get_node("CollisionShape2D").position == Vector2(0, -1), "Collider unchanged")
		Input.action_release("move_right")
		Input.action_release("run")
	# Semantic action drives the real player branch, not a keyboard literal.
	player.visual.set_pose("idle", "up")
	Input.action_press("attack_primary")
	player._physics_process(1.0 / 60.0)
	check(player.attacking and player.visual.direction == "up", "Semantic action starts attack")
	Input.action_release("attack_primary")
	player.visual.advance(1.2)
	var overlay: CanvasLayer = main.get_node("DebugOverlay")
	check("Move / Direction" in overlay.hint.text and "LMB / J" in overlay.hint.text and not "B boar" in overlay.hint.text, "Clean legend")
	var b := InputEventKey.new()
	b.keycode = KEY_B
	b.pressed = true
	var boar_mode: String = boar.ambient_state
	var boar_time: float = boar.remaining
	overlay._unhandled_key_input(b)
	check(boar.ambient_state == boar_mode and boar.remaining == boar_time, "B has no runtime effect")
	for key: int in [KEY_F1, KEY_F2, KEY_F3]:
		var event := InputEventKey.new()
		event.keycode = key
		event.pressed = true
		overlay._unhandled_key_input(event)
	check(overlay.debug_visible and player.visual.guides and boar.visual.guides and player.visual.separate_shadow, "F1/F2/F3 retained")
	check(world.get_node("Actors").y_sort_enabled, "Actors use dynamic Y-sort")
	check(world.get_node("Actors").find_children("Tree*", "StaticBody2D", false, false).size() >= 4, "Four-plus native trees")
	check(world.get_node("Actors/House").get_child(0).shape.size == Vector2(128, 40), "House footprint excludes roof")
	var grass := HOME.resolve(int(DATA.data.world.home.base_grass_gid), world.home_mapping.tilesets)
	var native_grass := image(grass.file).get_region(grass.region)
	check(native_grass.get_used_rect() == Rect2i(0, 0, 16, 16), "Opaque native background grass")
	var source_grass_verified := false
	for layer: Dictionary in world.home_mapping.layers:
		if layer.id == 23:
			for cell: Dictionary in layer.cells:
				if cell.gid == int(DATA.data.world.home.base_grass_gid):
					source_grass_verified = true
	check(source_grass_verified, "Base grass GID is grounded in original TMX Grass layer")
	var terrain_cells := 0
	var flips := 0
	for layer: Dictionary in world.home_mapping.layers:
		var spec: Dictionary = DATA.data.world.home
		if not (PackedInt32Array(spec.terrain_layer_ids).has(int(layer.id)) or PackedInt32Array(spec.house_layer_ids).has(int(layer.id)) or layer.id == int(spec.fence_layer_id)):
			continue
		for cell: Dictionary in layer.cells:
			var tile := HOME.resolve(cell.gid, world.home_mapping.tilesets)
			check(FileAccess.file_exists(tile.file), "Selected TMX dependency exists: " + str(tile.file).get_file())
			check(Rect2i(Vector2i.ZERO, image(tile.file).get_size()).encloses(tile.region), "Exact original GID stays within atlas")
			if int(tile.flags) != 0:
				flips += 1
			terrain_cells += 1
	check(terrain_cells > 1200 and flips > 0, "Native source layers and Tiled flip flags preserved")
	for gid: int in [788, 789]:
		var source_x := -4 if gid == 788 else -3
		check(world.get_node("Actors/Fence_%d_6" % source_x).find_children("*", "CollisionShape2D", true, false).is_empty(), "Source gate remains walkable")
	# Boar idle preserves facing; travel derives it from observed velocity.
	# Run accelerated simulation within a real physics tick so move_and_slide uses
	# the same fixed 1/60s delta as the timer, rather than render-frame timing.
	await physics_frame
	boar.rng.seed = 20261004
	boar.position = Vector2(640, 432)
	boar._idle()
	boar.remaining = 10
	var boar_origin: Vector2 = boar.position
	var facing: String = boar.visual.direction
	for i in range(240):
		boar._physics_process(1.0 / 60.0)
		check(boar.position == boar_origin and boar.visual.direction == facing and boar.visual.state == "idle", "No timed idle rotation")
	for axis: Vector2 in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		boar.position = Vector2(640, 432)
		boar.target = boar.position + axis * 24
		boar.ambient_state = "walk"
		boar.remaining = 2
		boar._physics_process(1.0 / 60.0)
		check(boar.visual.direction == PlayerV2.facing_for(boar.velocity, facing) and boar.visual.state == "walk", "Boar observed velocity chooses facing")
	var walked := 0
	var waited := 0
	for i in range(7200):
		boar._physics_process(1.0 / 60.0)
		check(boar.roam_area.has_point(boar.position), "Boar remains bounded over 120 seconds")
		if not boar.velocity.is_zero_approx():
			walked += 1
			check(boar.visual.state == "walk" and boar.visual.direction == PlayerV2.facing_for(boar.velocity, facing), "Natural walk/facing matches movement")
		else:
			waited += 1
	check(walked > 300 and waited > 300, "Ambient alternates travel and idle")
	check(boar.get_node("CollisionShape2D").shape.size == Vector2(16, 8) and boar.collision_mask == 2, "Fixed ambient footprint/environment-only mask")
	# Actual physics steps prove the source gate and footprint geometry, not just nodes.
	# Clear the earlier same-frame semantic attack press before re-enabling physics.
	await physics_frame
	await process_frame
	player.set_physics_process(true)
	player.position = Vector2(488, 326)
	Input.action_press("move_up")
	for i in range(60):
		await physics_frame
	Input.action_release("move_up")
	check(player.position.y > 306 and player.position.y < 310, "House front wall blocks at footprint, not roof")
	player.position = Vector2(488, 390)
	Input.action_press("move_up")
	for i in range(50):
		await physics_frame
	Input.action_release("move_up")
	check(player.position.y >= 371 and player.position.y < 375, "Fence rail blocks at its base")
	player.position = Vector2(520, 390)
	Input.action_press("move_up")
	for i in range(80):
		await physics_frame
	Input.action_release("move_up")
	check(player.position.y < 335, "32px original gate is physically traversable")
	player.position = Vector2(414, 250)
	Input.action_press("move_right")
	for i in range(50):
		await physics_frame
	Input.action_release("move_right")
	check(player.position.x > 445 and absf(player.position.y - 250) < 0.1, "Roof overhang remains walkable outside house footprint")
	main.free()
	print("DEV-R001.1 %s: %d checks, %d failures; attack source/pixels/non-loop/input/root, native home/map/gate, controls and 120-second bounded ambient wander." % ["PASS" if failures == 0 else "FAIL", checks, failures])
	quit(0 if failures == 0 else 1)
