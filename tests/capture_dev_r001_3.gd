extends SceneTree

var evidence: Array = []
var player: PlayerV2
var boar: CharacterBody2D
var attack_finishes := 0

func _initialize() -> void:
	call_deferred("capture")

func feet(body: CharacterBody2D) -> Rect2:
	var collider := body.get_node("CollisionShape2D") as CollisionShape2D
	return Rect2(collider.global_position - collider.shape.size/2,collider.shape.size)

func save_display(filename: String) -> bool:
	player.visual.queue_redraw()
	boar.visual.queue_redraw()
	for i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	var displayed := root.get_texture().get_image()
	var native_size := DisplayServer.window_get_size(root.get_window_id())
	var scale := root.get_stretch_transform().get_scale()
	var intersection := feet(player).intersection(feet(boar))
	var overlap := maxf(0,intersection.size.x) * maxf(0,intersection.size.y)
	if native_size != Vector2i(1280,720) or displayed.get_size() != native_size or root.content_scale_size != Vector2i(640,360) or not scale.is_equal_approx(Vector2(2,2)) or overlap > 0.001:
		push_error("Capture requires native1280x720, logical640x360, exact2x and nonpenetrating actor contact")
		return false
	if displayed.save_png("res://docs/screenshots/" + filename) != OK:
		return false
	var player_feet := feet(player)
	var boar_feet := feet(boar)
	evidence.append({"file":filename,"window_size":[native_size.x,native_size.y],"framebuffer_size":[displayed.get_width(),displayed.get_height()],"logical_size":[640,360],"stretch_scale":[scale.x,scale.y],"F2":debug_collisions_hint,"method":"actual displayed root Window framebuffer; no image resizing","player":{"position":str(player.position),"feet":str(player_feet),"state":player.visual.state,"facing":player.visual.direction,"frame":player.visual.frame_index},"boar":{"position":str(boar.position),"feet":str(boar_feet),"state":boar.ambient_state},"penetration_area":overlap,"vertical_contact_gap":maxf(player_feet.position.y-boar_feet.end.y,boar_feet.position.y-player_feet.end.y),"attack_finishes":attack_finishes})
	print("Captured " + filename + " / native1280x720 /2x / actor penetration area " + str(overlap))
	return true

func capture() -> void:
	root.content_scale_size = Vector2i(640,360)
	root.size = Vector2i(1280,720)
	var main: Node2D = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	player = main.get_node("TestWorld/Actors/Player")
	boar = main.get_node("TestWorld/Actors/BoarPreview")
	player.set_physics_process(false)
	player.visual.set_process(false)
	boar.set_physics_process(false)
	boar.visual.set_process(false)
	player.visual.animation_finished.connect(func(_state: String): attack_finishes += 1)
	var camera := player.get_node("Camera2D") as Camera2D
	camera.top_level = true
	camera.position = Vector2(560,340)
	for i in range(10):
		await process_frame
	DisplayServer.window_set_size(Vector2i(1280,720),root.get_window_id())
	var f2 := InputEventKey.new()
	f2.keycode = KEY_F2
	f2.pressed = true
	main.get_node("DebugOverlay")._unhandled_key_input(f2)
	assert(debug_collisions_hint and player.visual.guides and boar.visual.guides)
	for from_below: bool in [true,false]:
		boar.position = Vector2(640,432)
		boar.visual.set_pose("idle","left")
		player.position = Vector2(640,470 if from_below else 396)
		player.visual.sword = false
		player.visual.set_pose("idle","up" if from_below else "down")
		await physics_frame
		var action := "move_up" if from_below else "move_down"
		Input.action_press(action)
		var before := player.position
		for tick in range(90):
			player._physics_process(1.0/60.0)
			player.visual.advance(1.0/60.0)
		Input.action_release(action)
		player._physics_process(1.0/60.0)
		assert(player.position.distance_to(before) < 36 and player.velocity.is_zero_approx())
		var filename := "dev-r001-3-player-boar-collision.png" if from_below else "dev-r001-3-player-boar-y-sort-above.png"
		if not await save_display(filename):
			main.free()
			quit(1)
			return
	player.position = Vector2(640,470)
	player.visual.sword = true
	player.visual.set_pose("idle","up")
	await physics_frame
	assert(player.start_attack(Vector2.UP,true))
	for tick in range(36):
		player._physics_process(1.0/60.0)
		player.visual.advance(1.0/60.0)
	assert(player.attacking and player.velocity.is_zero_approx() and player.visual.frame_index > 0)
	if not await save_display("dev-r001-3-run-attack-boar-block.png"):
		main.free()
		quit(1)
		return
	for tick in range(36):
		player._physics_process(1.0/60.0)
		player.visual.advance(1.0/60.0)
	assert(not player.attacking and player.visual.state == "idle" and attack_finishes == 1)
	var file := FileAccess.open("res://docs/reports/dev-r001-3-display-evidence.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(evidence,"\t") + "\n")
	main.free()
	quit()
