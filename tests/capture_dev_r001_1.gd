extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func save_frame(filename: String) -> void:
	for node: Node in get_nodes_in_group("source_capture"):
		node.queue_redraw()
	for i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	assert(image.get_size() == Vector2i(640, 360), "Native 1x gameplay capture")
	assert(image.save_png("res://docs/screenshots/" + filename) == OK)
	print("Captured " + filename)

func capture() -> void:
	root.content_scale_size = Vector2i(640, 360)
	root.size = Vector2i(640, 360)
	var main: Node2D = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	for i in range(75):
		await physics_frame
	var world: Node2D = main.get_node("TestWorld")
	var player := world.get_node("Actors/Player") as PlayerV2
	var camera := player.get_node("Camera2D") as Camera2D
	player.input_enabled = false
	player.visual.set_process(false)
	player.visual.add_to_group("source_capture")
	var boar: CharacterBody2D = world.get_node("Actors/BoarPreview")
	boar.set_physics_process(false)
	boar.visual.set_process(false)
	boar.visual.add_to_group("source_capture")
	# Keep one native camera frame fixed for useful before/after comparison.
	camera.top_level = true
	camera.position = Vector2(488, 320)
	camera.reset_smoothing()
	player.visual.set_pose("idle", "down")
	await save_frame("dev-r001-1-playtest-area.png")
	player.position = Vector2(504, 326)
	player.visual.set_pose("walk", "up")
	player.visual.frame_index = 2
	await save_frame("dev-r001-1-house-fence.png")
	player.visual.set_pose("idle", "down")
	player.position = Vector2(336, 351)
	await save_frame("dev-r001-1-tree-behind.png")
	player.position = Vector2(336, 370)
	await save_frame("dev-r001-1-tree-front.png")
	player.position = Vector2(480, 392)
	player.visual.sword = true
	player.visual.set_pose("idle", "down")
	await save_frame("dev-r001-1-sword-idle.png")
	for direction: String in ["down", "left", "right", "up"]:
		player.start_attack()
		player.visual.set_pose("attack", direction)
		player.visual.frame_index = 4
		await save_frame("dev-r001-1-sword-attack-%s.png" % direction)
		player.visual.advance(1.2)
	# Observe actual ambient travel rather than setting a pretend animation pose.
	player.visual.set_pose("idle", "down")
	boar.visual.set_process(true)
	boar.set_physics_process(true)
	boar._idle()
	while boar.velocity.is_zero_approx():
		await physics_frame
	for i in range(20):
		await physics_frame
	await save_frame("dev-r001-1-boar-walk-a.png")
	for i in range(20):
		await physics_frame
	await save_frame("dev-r001-1-boar-walk-b.png")
	boar.set_physics_process(false)
	boar.visual.set_process(false)
	player.visual.guides = true
	boar.visual.guides = true
	main.get_node("DebugOverlay").debug_visible = true
	debug_collisions_hint = true
	await save_frame("dev-r001-1-debug-footprints.png")
	main.free()
	quit()
