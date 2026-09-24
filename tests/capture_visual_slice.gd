extends SceneTree


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var packed := load("res://scenes/main/main.tscn") as PackedScene
	var main := packed.instantiate()
	root.add_child(main)
	var player := main.get_node("PrototypeZone/Player") as PlayerController
	player.global_position = Vector2(560, 400)
	player.get_node("Camera2D").zoom = Vector2(0.6, 0.6)
	for _frame in range(6):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	var output := ProjectSettings.globalize_path("res://docs/screenshots/dev-002-visual-slice.png")
	var error := image.save_png(output)
	if error != OK:
		push_error("Could not save visual-slice screenshot: %s" % error_string(error))
		quit(1)
		return
	print("Saved screenshot: %s" % output)
	quit(0)
