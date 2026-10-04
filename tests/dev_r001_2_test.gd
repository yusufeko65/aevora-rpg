extends SceneTree

const DATA := preload("res://data/source_mapping/craftpix.json")
const AUDIT := preload("res://data/source_mapping/craftpix_audit.json")
const LAYER_AUDIT := preload("res://tests/audit_moving_attack_layers.gd")
const SPRITE := preload("res://systems/animation/source_sprite.gd")
const HOME := preload("res://scenes/world/home_source.gd")
var checks := 0
var failures := 0
var finishes := 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(value: bool,message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func key(code: int,pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func rect(collider: CollisionShape2D) -> Rect2:
	return Rect2(collider.global_position - collider.shape.size/2,collider.shape.size)

func run_tests() -> void:
	check(ProjectSettings.get_setting("display/window/size/viewport_width") == 640 and ProjectSettings.get_setting("display/window/size/viewport_height") == 360,"Logical 640x360 preserved")
	check(ProjectSettings.get_setting("display/window/size/window_width_override") == 1280 and ProjectSettings.get_setting("display/window/size/window_height_override") == 720,"Display 1280x720 preserved")
	check(ProjectSettings.get_setting("display/window/stretch/scale_mode") == "integer" and ProjectSettings.get_setting("display/window/stretch/mode") == "canvas_items","Pixel-safe integer canvas_items display")
	var arrows := {"move_up":KEY_UP,"move_down":KEY_DOWN,"move_left":KEY_LEFT,"move_right":KEY_RIGHT}
	print("Godot physical Arrow codes: " + JSON.stringify(arrows))
	var aliases := {"move_up":KEY_W,"move_down":KEY_S,"move_left":KEY_A,"move_right":KEY_D}
	for action: String in arrows:
		var events := InputMap.action_get_events(action)
		check(events.size() == 2 and events[0].physical_keycode == arrows[action] and events[1].physical_keycode == aliases[action],"Physical Arrow primary and WASD secondary: " + action)
		key(arrows[action],true)
		check(Input.is_action_pressed(action),"Arrow produces semantic action: " + action)
		key(arrows[action],false)
		check(not Input.is_action_pressed(action),"Arrow release: " + action)
	var auditor := LAYER_AUDIT.new()
	var sprite := SPRITE.new()
	root.add_child(sprite)
	sprite.set_process(false)
	sprite.sword = true
	sprite.animation_finished.connect(func(_state: String): finishes += 1)
	for family: String in ["walk_attack","run_attack"]:
		var pose: Dictionary = DATA.data.human.states[family]
		var count := 6 if family == "walk_attack" else 8
		check(pose.frame_count == count and not pose.loop,"Source count/non-loop: " + family)
		for layer: Dictionary in pose.sword_layers + [pose.sword_full,pose.sword_full_with_shadow]:
			check(auditor.image(layer.file).get_size() == Vector2i(count*64,256),"Exact source sheet geometry")
			var found := false
			for tileset: Dictionary in AUDIT.data.source_tmx["main_character/male/Base_boy.tmx"].tilesets:
				if tileset.source == str(layer.file).get_file():
					found = true
					check(layer.source_columns == tileset.logical_sequences,"Original explicit TMX timeline")
			check(found,"Layer has TMX evidence")
		for direction: String in ["down","left","right","up"]:
			sprite.set_pose(family,direction)
			var previous := finishes
			for step in range(count):
				check(sprite.frame_index == step and sprite.duration_ms() == 150,"Exact 150ms source step")
				var row := sprite.source_row()
				for shadow: bool in [false,true]:
					var full: Dictionary = pose.sword_full_with_shadow if shadow else pose.sword_full
					var expected := auditor.image(full.file).get_region(Rect2i(sprite.source_region(full)))
					check(auditor.differences(auditor.composite(pose,row,step,[0,1,2,3,4],shadow),expected) == 0,"All moving-attack source pixels including shadow match")
				sprite.advance(0.149)
				check(sprite.frame_index == step and finishes == previous,"Final frame receives full duration")
				sprite.advance(0.001)
			check(sprite.finished and sprite.frame_index == count-1 and finishes == previous+1,"No wrap; finish once")
			sprite.advance(10)
			check(finishes == previous+1,"No repeated finish")
	sprite.free()
	auditor.free()
	var main: Node2D = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	var world: Node2D = main.get_node("TestWorld")
	var player := world.get_node("Actors/Player") as PlayerV2
	player.set_physics_process(false)
	player.visual.set_process(false)
	var boar: CharacterBody2D = world.get_node("Actors/BoarPreview")
	boar.set_physics_process(false)
	var hint: String = main.get_node("DebugOverlay").hint.text
	check("↑ ↓ ← →" in hint and not "WASD" in hint and not "B boar" in hint,"Arrow-primary legend, no B")
	await physics_frame
	for action: String in arrows:
		player.position = Vector2(480,500)
		key(arrows[action],true)
		player._physics_process(1.0/60.0)
		check(player.visual.direction == action.trim_prefix("move_") and player.position != Vector2(480,500),"Actual arrow moves and faces: " + action)
		key(arrows[action],false)
	key(KEY_RIGHT,true)
	key(KEY_W,true)
	check(Input.get_vector("move_left","move_right","move_up","move_down").is_equal_approx(Vector2(1,-1).normalized()),"Arrow and alternate WASD form normalized diagonal")
	key(KEY_W,false)
	check(Input.is_action_pressed("move_right"),"Releasing alias does not disturb held arrow")
	key(KEY_RIGHT,false)
	# Source alpha is measured once and compared with static profile data, not runtime collision generation.
	for gid: int in [802,804]:
		var tile := HOME.resolve(gid,world.home_mapping.tilesets)
		var image := Image.new()
		check(image.load_png_from_buffer(FileAccess.get_file_as_bytes(tile.file)) == OK,"Fence PNG original loads")
		var bounds := image.get_region(tile.region).get_used_rect()
		var profile: Dictionary = DATA.data.world.home.fence_collision_profiles[str(gid)]
		check(profile.measured_opaque_bounds == [float(bounds.position.x),float(bounds.position.y),float(bounds.size.x),float(bounds.size.y)],"Measured cap bounds grounded in pixels")
		check(profile.shapes[0].size[0] < 16,"Only measured cap narrowed")
	for side_x: int in [-12,1]:
		var last_side := rect(world.get_node("Actors/Fence_%d_5" % side_x).find_children("*","CollisionShape2D",true,false)[0])
		var corner := world.get_node("Actors/Fence_%d_6" % side_x).find_children("*","CollisionShape2D",true,false)
		check(corner.size() == 2,"Corner has vertical and horizontal components")
		var vertical := rect(corner[0])
		check(last_side.end.y == vertical.position.y and last_side.position.x == vertical.position.x,"12px former gap is now zero with aligned vertical connection")
	# Accelerated physical attempts inside a real fixed physics tick.
	for side_x: int in [-12,1]:
		for y in [252,300,358]:
			var start := Vector2(366 if side_x == -12 else 611,y)
			player.position = start
			var action := "move_right" if side_x == -12 else "move_left"
			Input.action_press(action)
			for i in range(70):
				player._physics_process(1.0/60.0)
			Input.action_release(action)
			check(player.position.x < 386 if side_x == -12 else player.position.x > 590,"Side upper/middle/lower blocks x=%d y=%d" % [side_x,y])
	for left: bool in [true,false]:
		player.position = Vector2(404 if left else 574,338)
		Input.action_press("move_left" if left else "move_right")
		Input.action_press("move_down")
		for i in range(70):
			player._physics_process(1.0/60.0)
		Input.action_release("move_left" if left else "move_right")
		Input.action_release("move_down")
		check(player.position.x > 395 if left else player.position.x < 582,"Diagonal bottom seam cannot leak")
	for down: bool in [true,false]:
		player.position = Vector2(520,336 if down else 390)
		Input.action_press("move_down" if down else "move_up")
		for i in range(75):
			player._physics_process(1.0/60.0)
		Input.action_release("move_down" if down else "move_up")
		check(player.position.y > 380 if down else player.position.y < 340,"Gate passes both directions")
	for x in [379,598]:
		player.position = Vector2(x,220)
		Input.action_press("move_down")
		for i in range(50):
			player._physics_process(1.0/60.0)
		Input.action_release("move_down")
		check(player.position.y > 250,"Outside visible cap not blocked x=%d" % x)
	for x in [389,588]:
		player.position = Vector2(x,220)
		Input.action_press("move_down")
		for i in range(50):
			player._physics_process(1.0/60.0)
		Input.action_release("move_down")
		check(player.position.y < 235,"Visible cap blocks x=%d" % x)
	# Start-family selection, captured direction/speed and exact fixed-tick unobstructed distances.
	player.visual.sword = true
	for selection: Dictionary in [{"state":"attack","key":0,"run":false,"axis":Vector2.ZERO},{"state":"walk_attack","key":KEY_RIGHT,"run":false,"axis":Vector2.RIGHT},{"state":"run_attack","key":KEY_UP,"run":true,"axis":Vector2.UP}]:
		await physics_frame
		player.position = Vector2(480,500)
		if selection.key != 0:
			key(selection.key,true)
		if selection.run:
			key(KEY_SHIFT,true)
		key(KEY_J,true)
		# Parsed OS events are just-pressed for the next fixed physics tick.
		await physics_frame
		player._physics_process(1.0/60.0)
		check(player.attacking and player.visual.state == selection.state,"Physical attack input selects current locomotion family")
		check(player.attack_velocity.is_equal_approx(selection.axis * (112 if selection.run else 48)),"Physical input captures speed/vector, standing attack remains still")
		key(KEY_J,false)
		if selection.key != 0:
			key(selection.key,false)
		key(KEY_SHIFT,false)
		player.visual.advance(2)
		check(not player.attacking and player.visual.state == "idle","Released physical input returns to Sword Idle")
	var distances: Dictionary = {}
	for running: bool in [false,true]:
		player.position = Vector2(430,500)
		var before := player.position
		check(player.start_attack(Vector2.RIGHT,running),"Moving attack starts")
		var family := "run_attack" if running else "walk_attack"
		check(player.visual.state == family and player.visual.direction == "right","Correct movement family/facing")
		Input.action_press("move_up")
		var frames := 72 if running else 54
		for i in range(frames):
			player._physics_process(1.0/60.0)
			player.visual.advance(1.0/60.0)
			if i < frames-1:
				check(player.attacking and player.visual.direction == "right","Steering changes ignored until completion")
				check(not player.start_attack(Vector2.LEFT,not running),"Spam cannot change active family/direction")
				player.toggle_sword()
				check(player.visual.sword,"Tab ignored during moving attack")
		var distance := player.position.distance_to(before)
		distances[family] = distance
		check(absf(distance-(134.4 if running else 43.2)) < 0.01,"Measured expected unobstructed travel")
		check(not player.attacking and player.visual.state == "walk" and player.visual.direction == "up","Return to current live input, not start state")
		Input.action_release("move_up")
		player.visual.set_pose("idle","right")
	# Run attack toward each major environment: root blocks but one-shot completes.
	for fixture: Dictionary in [{"name":"fence","at":Vector2(488,390)},{"name":"house","at":Vector2(488,326)},{"name":"tree","at":Vector2(336,398)}]:
		player.position = fixture.at
		check(player.start_attack(Vector2.UP,true),"Collision attack starts")
		for i in range(72):
			player._physics_process(1.0/60.0)
			player.visual.advance(1.0/60.0)
		check(player.position.distance_to(fixture.at) < 40 and not player.attacking and player.visual.state == "idle","Moving attack blocked by %s and still finishes" % fixture.name)
	check(player.get_node("CollisionShape2D").shape.size == Vector2(10,6) and player.visual.mapping.pivot == [32.0,44.0],"Unchanged root/pivot/feet")
	print("DEV-R001.2 %s: %d checks, %d failures; arrows, measured fence profiles/traversal/gate, all moving-attack source pixels/timing/lock/collision. Travel: %s" % ["PASS" if failures == 0 else "FAIL",checks,failures,JSON.stringify(distances)])
	main.free()
	quit(0 if failures == 0 else 1)
