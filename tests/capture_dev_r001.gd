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
	assert(image.get_size() == Vector2i(640, 360), "Capture must be actual logical gameplay scale")
	assert(image.save_png("res://docs/screenshots/" + filename) == OK)
	print("Captured " + filename)

func capture() -> void:
	root.content_scale_size = Vector2i(640, 360)
	root.size = Vector2i(640, 360)
	var main := load("res://scenes/main/main.tscn").instantiate() as Node2D
	root.add_child(main)
	# Let rendering settle so the FPS monitor describes steady runtime, not startup.
	for i in range(75):
		await physics_frame
	var player := main.get_node("TestWorld/Actors/Player") as PlayerV2
	player.input_enabled = false
	player.visual.set_process(false)
	player.visual.add_to_group("source_capture")
	var boar := main.get_node("TestWorld/Actors/BoarPreview")
	boar.set_process(false)
	boar.visual.set_process(false)
	boar.visual.add_to_group("source_capture")
	for pose: Array in [["idle", "down", 0], ["walk", "left", 1], ["run", "right", 3]]:
		player.visual.set_pose(pose[0], pose[1])
		player.visual.frame_index = pose[2]
		await save_frame("dev-r001-%s-%s.png" % [pose[0], pose[1]])
	player.visual.set_pose("idle", "down")
	player.visual.guides = true
	boar.visual.guides = true
	main.get_node("DebugOverlay").debug_visible = true
	debug_collisions_hint = true
	await save_frame("dev-r001-debug-feet.png")
	player.visual.guides = false
	boar.visual.guides = false
	main.get_node("DebugOverlay").debug_visible = false
	debug_collisions_hint = false
	player.visual.separate_shadow = true
	await save_frame("dev-r001-shadow-b.png")
	player.visual.sword = true
	player.visual.set_pose("walk", "right")
	player.visual.frame_index = 4
	await save_frame("dev-r001-sword-layers.png")
	main.free()
	# A separate inspection board uses the same source player, native 1x frames.
	var board := Node2D.new()
	board.set_script(load("res://scenes/dev/source_review.gd"))
	root.add_child(board)
	await save_frame("dev-r001-all-directions.png")
	board.free()
	quit()
