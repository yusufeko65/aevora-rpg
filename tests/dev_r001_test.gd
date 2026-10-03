extends SceneTree

const DATA := preload("res://data/source_mapping/craftpix.json")
const AUDIT := preload("res://data/source_mapping/craftpix_audit.json")
const SPRITE := preload("res://systems/animation/source_sprite.gd")
const PLAYER := preload("res://scenes/player/player.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
		quit(1)
		assert(value, message)

func raw_image(path: String) -> Image:
	var image := Image.new()
	check(image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK, "PNG decode: " + path)
	return image

func run_tests() -> void:
	check(ProjectSettings.get_setting("display/window/size/viewport_width") == 640, "640 viewport")
	check(ProjectSettings.get_setting("display/window/size/viewport_height") == 360, "360 viewport")
	check(ProjectSettings.get_setting("display/window/stretch/scale_mode") == "integer", "Integer window scale")
	check(ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility", "Compatibility renderer")
	check(OS.find_keycode_from_string("Shift") == InputMap.action_get_events("run")[0].physical_keycode, "Shift run binding")
	check(DATA.data.human.direction_rows == {"down": 0.0, "left": 1.0, "right": 2.0, "up": 3.0}, "Explicit human rows")
	check(DATA.data.boar.direction_rows == {"down": 0.0, "up": 1.0, "left": 2.0, "right": 3.0}, "Explicit boar rows")
	for path: String in AUDIT.data.source_tmx:
		check(FileAccess.get_sha256("res://art/vendor/craftpix/" + path) == AUDIT.data.source_tmx[path].sha256, "Unchanged TMX bytes")
		check(AUDIT.data.source_tmx[path].tile_size == [16.0, 16.0], "Original 16x16 Tiled grid")
	var grass_image := raw_image("res://art/vendor/craftpix/tile/path_and_road/Ground_grass.png")
	for y in range(32, 48):
		for x in range(32, 48):
			check(grass_image.get_pixel(x, y).a == 1, "Verified opaque ground tile (2,2)")
	for path: String in AUDIT.data.images:
		var full_path := "res://art/vendor/craftpix/" + path
		check(FileAccess.get_sha256(full_path) == AUDIT.data.images[path].sha256, "Unchanged vendor bytes: " + path)
		var img := raw_image(full_path)
		check(img.get_width() == int(AUDIT.data.images[path].size[0]) and img.get_height() == int(AUDIT.data.images[path].size[1]), "Audited dimensions: " + path)
		var texture := load(full_path) as Texture2D
		check(texture != null and not texture.get_image().has_mipmaps(), "Imported lossless/no mipmaps: " + path)
		var import_config := ConfigFile.new()
		check(import_config.load(full_path + ".import") == OK, "Texture import exists")
		check(import_config.get_value("params", "compress/mode") == 0 and import_config.get_value("params", "process/size_limit") == 0, "Lossless native-sized import")
	for kind: String in ["human", "boar"]:
		var sprite := SPRITE.new()
		sprite.source_kind = kind
		root.add_child(sprite)
		sprite.set_process(false)
		var expected := {"idle": 12, "walk": 6, "run": 8} if kind == "human" else {"idle": 4, "walk": 6}
		for state: String in sprite.mapping.states:
			check(sprite.mapping.states[state].frame_count == expected[state], "Source frame count: " + state)
			var pose: Dictionary = sprite.mapping.states[state]
			var tmx_layers: Array = [pose.unarmed_full, pose.unarmed_body, pose.sword_full] + pose.sword_layers if kind == "human" else [pose.full]
			for layer: Dictionary in tmx_layers:
				verify_tmx(layer, kind, pose.durations_ms)
			for direction: String in sprite.mapping.direction_rows:
				sprite.set_pose(state, direction)
				for i in range(int(sprite.mapping.states[state].frame_count)):
					check(sprite.frame_index == i, "150ms timeline step")
					check(sprite.duration_ms() == 150, "Source timing")
					var full: Dictionary = pose.unarmed_full if kind == "human" else pose.full
					var texture := load(full.file) as Texture2D
					var cell: int = sprite.mapping.frame_size
					check(texture.get_size() == Vector2(expected[state] * cell, 4 * cell), "Exact independent source sheet geometry")
					if kind == "human":
						verify_layers(sprite, [pose.shadow, pose.unarmed_body], pose.unarmed_full)
						verify_layers(sprite, pose.sword_layers, pose.sword_full)
					else:
						verify_region(sprite, pose.full)
					sprite.advance(0.15)
				check(sprite.frame_index == 0 and absf(sprite.elapsed_ms) < 0.0001, "Loop exact source cycle")
			sprite.set_pose(state, "down")
			sprite.advance(2.0 * int(sprite.mapping.states[state].frame_count) * 0.15 + 0.075)
			check(sprite.frame_index == 0 and absf(sprite.elapsed_ms - 75) < 0.01, "Playback preserves leftover time across large delta")
		sprite.free()
	check(PLAYER.facing_for(Vector2(1, -1), "down") == "right", "Diagonal horizontal priority")
	check(PLAYER.facing_for(Vector2(-1, 1), "up") == "left", "Diagonal horizontal priority left")
	check(PLAYER.facing_for(Vector2.ZERO, "up") == "up", "Idle preserves facing")
	var main := load("res://scenes/main/main.tscn").instantiate() as Node2D
	root.add_child(main)
	await process_frame
	var world := main.get_node("TestWorld")
	var player := world.get_node("Actors/Player") as PlayerV2
	player.input_enabled = false
	check(world.get_node("Ground16").tile_set.tile_size == Vector2i(16, 16), "16px source terrain, not 32px slicing")
	check(world.get_node("RoadPatch16").get_used_cells().size() == 55, "Small native 5x11 road patch")
	check(world.get_node("Actors/Tree64/Sprite2D").texture.get_size() == Vector2(64, 64), "Native Tree64")
	check(world.get_node("Actors/Tree128/Sprite2D").texture.get_size() == Vector2(128, 128), "Native Tree128")
	check(player.get_node("CollisionShape2D").shape.size == Vector2(10, 6), "Small fixed foot collider")
	var original_position := player.position
	for key: int in [KEY_F1, KEY_F2, KEY_F3, KEY_TAB, KEY_B]:
		var event := InputEventKey.new()
		event.keycode = key
		event.pressed = true
		main.get_node("DebugOverlay")._unhandled_key_input(event)
		check(player.position == original_position, "Debug/source toggles leave world root untouched")
	check(main.get_node("DebugOverlay").debug_visible and player.visual.guides and player.visual.separate_shadow and player.visual.sword, "Debug, guides, shadow and sword toggles")
	check(world.get_node("Actors/BoarPreview").preview_mode == "walk", "Boar preview state toggle")
	for state: String in player.visual.mapping.states:
		for direction: String in player.visual.mapping.direction_rows:
			player.visual.set_pose(state, direction)
			player.visual.sword = not player.visual.sword
			player.visual.separate_shadow = not player.visual.separate_shadow
			player.visual.guides = not player.visual.guides
			player.visual.advance(1.25)
			check(player.position == original_position, "Visual state cannot move physics root")
			check(player.get_node("CollisionShape2D").position == Vector2(0, -1), "Fixed collider offset")
	player.input_enabled = true
	player.position = Vector2(480, 400)
	Input.action_press("move_right")
	for i in range(30):
		await physics_frame
	Input.action_release("move_right")
	check(absf(player.position.x - 504) < 2, "Walk speed independent of 150ms sprite timing")
	Input.action_press("move_right")
	Input.action_press("run")
	var run_start := player.position.x
	for i in range(30):
		await physics_frame
	Input.action_release("move_right")
	Input.action_release("run")
	check(absf(player.position.x - run_start - 56) < 2, "Run speed independent of source frame count")
	player.position = Vector2(700, 400)
	Input.action_press("move_right")
	Input.action_press("move_up")
	Input.action_press("run")
	for i in range(30):
		await physics_frame
	Input.action_release("move_right")
	Input.action_release("move_up")
	Input.action_release("run")
	check(absf(player.position.distance_to(Vector2(700, 400)) - 56) < 2, "Normalized diagonal run distance")
	check(player.visual.direction == "right", "Stable diagonal facing in actual physics")
	player.position = Vector2(400, 318)
	Input.action_press("move_up")
	for i in range(100):
		await physics_frame
	Input.action_release("move_up")
	check(player.position.y >= 284 and player.position.y < 290, "Tree64 trunk blocks, not the whole canopy")
	player.position = Vector2(435, 318)
	Input.action_press("move_up")
	for i in range(100):
		await physics_frame
	Input.action_release("move_up")
	check(player.position.y < 250, "Canopy margin remains walkable")
	main.free()
	if failures == 0:
		print("DEV-R001 PASS: %d checks; geometry, TMX timelines, all 4 directions, pixel layer reconstruction, timing, root, movement, collision and scene smoke." % checks)
	else:
		print("DEV-R001 FAIL: %d failed checks" % failures)
	quit(0 if failures == 0 else 1)

func verify_region(sprite: SourceSprite, layer: Dictionary) -> Image:
	var img := raw_image(layer.file)
	var rect := Rect2i(sprite.source_region(layer))
	check(Rect2i(Vector2i.ZERO, img.get_size()).encloses(rect), "Region remains inside sheet")
	var region := img.get_region(rect)
	# Repeated TMX idle cells must not select the transparent trailing columns.
	check(not region.is_invisible(), "No empty displayed source frame: " + str(layer.file))
	var cell: int = sprite.mapping.frame_size
	check(Rect2i(1, 1, cell - 2, cell - 2).encloses(region.get_used_rect()), "Clear cell borders; no source bleed")
	return region

func verify_tmx(layer: Dictionary, kind: String, durations: Array) -> void:
	var tmx := "main_character/male/Base_boy.tmx" if kind == "human" else "fauna/hunt_animal/Animals.tmx"
	var found := false
	for tileset: Dictionary in AUDIT.data.source_tmx[tmx].tilesets:
		if tileset.source == str(layer.file).get_file():
			found = true
			check(layer.source_columns == tileset.logical_sequences, "Exact verified TMX source columns: " + str(layer.file))
			for row: Dictionary in tileset.logical_sequences.values():
				check(row.durations_ms == durations, "Exact TMX per-step durations")
	check(found, "Mapping has original TMX evidence")

func verify_layers(sprite: SourceSprite, layers: Array, full: Dictionary) -> void:
	var expected := verify_region(sprite, full)
	var composition := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	composition.fill(Color.TRANSPARENT)
	for layer: Dictionary in layers:
		var img := raw_image(layer.file)
		var region := Rect2i(sprite.source_region(layer))
		check(Rect2i(Vector2i.ZERO, img.get_size()).encloses(region), "Layer uses shared original canvas")
		composition.blend_rect(img, region, Vector2i.ZERO)
	var differences := 0
	for y in range(64):
		for x in range(64):
			var a := composition.get_pixel(x, y)
			var b := expected.get_pixel(x, y)
			if absf(a.a - b.a) > 1.01 / 255.0 or (a.a > 0.01 and maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b))) > 1.01 / 255.0):
				differences += 1
	check(differences == 0, "Layer composition differs from full source: %s %s step%d (%d pixels)" % [sprite.state, sprite.direction, sprite.frame_index, differences])
