extends SceneTree

var evidence: Array = []
var captured_player: PlayerV2

func _initialize() -> void:
	call_deferred("capture")

func save_display(filename: String) -> void:
	for node: Node in get_nodes_in_group("source_capture"):
		node.queue_redraw()
	for i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	# canvas_items renders the root Window at actual display resolution. This is
	# not a 640px SubViewport texture and no image resize operation is used.
	var image := root.get_texture().get_image()
	var native_size := DisplayServer.window_get_size(root.get_window_id())
	print("Display probe: " + JSON.stringify({"native":str(native_size),"root":str(root.size),"framebuffer":str(image.get_size()),"scale":str(root.get_stretch_transform().get_scale()),"logical":str(root.content_scale_size),"screen":str(DisplayServer.screen_get_size())}))
	var scale := root.get_stretch_transform().get_scale()
	if native_size != Vector2i(1280, 720) or image.get_size() != native_size or root.content_scale_size != Vector2i(640, 360) or not scale.is_equal_approx(Vector2(2, 2)):
		push_error("Capture requires native 1280x720 framebuffer, logical 640x360 and exact 2x transform")
		quit(1)
		return
	assert(image.save_png("res://docs/screenshots/" + filename) == OK)
	evidence.append({"file":filename,"window_size":[native_size.x,native_size.y],"framebuffer_size":[image.get_width(),image.get_height()],"logical_size":[640,360],"stretch_scale":[scale.x,scale.y],"capture_method":"actual root Window display framebuffer; no PNG resizing"})
	evidence[-1].player = {"position":[captured_player.position.x,captured_player.position.y],"state":captured_player.visual.state,"facing":captured_player.visual.direction,"frame":captured_player.visual.frame_index}
	print("Captured native display " + filename + " / " + str(native_size) + " / scale " + str(scale))

func capture() -> void:
	root.content_scale_size = Vector2i(640,360)
	root.size = Vector2i(1280,720)
	var main: Node2D = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	for i in range(75):
		await physics_frame
	# Apply the exact client size after Windows has finished creating the window.
	DisplayServer.window_set_size(Vector2i(1280,720), root.get_window_id())
	for i in range(5):
		await process_frame
	var player := main.get_node("TestWorld/Actors/Player") as PlayerV2
	captured_player = player
	var boar: CharacterBody2D = main.get_node("TestWorld/Actors/BoarPreview")
	var camera := player.get_node("Camera2D") as Camera2D
	player.input_enabled = false
	player.visual.set_process(false)
	player.visual.add_to_group("source_capture")
	boar.set_physics_process(false)
	boar.visual.set_process(false)
	boar.visual.add_to_group("source_capture")
	camera.top_level = true
	camera.position = Vector2(488,320)
	assert(camera.zoom == Vector2.ONE)
	await save_display("dev-r001-2-display-1280x720.png")
	player.visual.guides = true
	boar.visual.guides = true
	debug_collisions_hint = true
	await save_display("dev-r001-2-fence-collision.png")
	debug_collisions_hint = false
	player.visual.guides = false
	boar.visual.guides = false
	main.get_node("DebugOverlay").debug_visible = true
	player.input_enabled = true
	var arrow := InputEventKey.new()
	arrow.physical_keycode = KEY_RIGHT
	arrow.keycode = KEY_RIGHT
	arrow.pressed = true
	player.position = Vector2(450,450)
	Input.parse_input_event(arrow)
	for i in range(15):
		await physics_frame
	await save_display("dev-r001-2-arrow-input.png")
	arrow.pressed = false
	Input.parse_input_event(arrow)
	player.input_enabled = false
	player.visual.sword = true
	main.get_node("DebugOverlay").debug_visible = false
	for running: bool in [false,true]:
		player.position = Vector2(420,450)
		player.input_enabled = true
		player.visual.set_process(true)
		player.start_attack(Vector2.RIGHT,running)
		for i in range(36 if running else 22):
			await physics_frame
		player.set_physics_process(false)
		player.visual.set_process(false)
		assert(player.position.x > 430, "Moving attack capture must observe real root translation")
		await save_display("dev-r001-2-%s.png" % player.visual.state)
		player.visual.advance(2)
		player.set_physics_process(true)
		player.input_enabled = false
	var file := FileAccess.open("res://docs/reports/dev-r001-2-display-evidence.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(evidence,"\t") + "\n")
	main.free()
	quit()
