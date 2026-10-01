extends SceneTree


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var packed := load("res://scenes/dev/character_visual_validation.tscn") as PackedScene
	var scene := packed.instantiate()
	root.add_child(scene)
	for _frame in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_viewport().get_texture().get_image()
	var output := ProjectSettings.globalize_path("res://docs/screenshots/dev-004-character-visual-validation.png")
	var error := image.save_png(output)
	if error != OK:
		push_error("Could not save DEV-004 validation screenshot: %s" % error_string(error))
		quit(1)
		return
	print("Saved DEV-004 validation screenshot: %s" % output)
	quit(0)
