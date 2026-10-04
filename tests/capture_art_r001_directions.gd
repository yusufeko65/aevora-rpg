extends SceneTree

const Review = preload("res://scenes/dev/art_r001_direction_review.gd")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.content_scale_size = Vector2i(640,360)
	root.size = Vector2i(1280,720)
	var scene: Node2D = Review.new()
	root.add_child(scene)
	var states := ["master"] if OS.get_environment("ART_R001_MASTER_ONLY") == "1" else ["master","idle","walk"]
	for state: String in states:
		scene.set_state(state)
		for i in range(3):
			await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		assert(image.get_size() == Vector2i(1280,720))
		var name := "master-4dir" if state == "master" else "%s-4dir" % state
		assert(image.save_png("res://docs/screenshots/art-r001-%s.png" % name) == OK)
		print("Captured native 1280x720 "+name)
	scene.free()
	quit(0)
