extends SceneTree

const Review = preload("res://scenes/dev/art_r001_source_review.gd")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.content_scale_size = Vector2i(640,360)
	root.size = Vector2i(1280,720)
	var scene: Node2D = Review.new()
	root.add_child(scene)
	var reports := {}
	var failures := 0
	for state: String in ["idle","walk"]:
		scene.set_animation(state)
		for frame: Dictionary in scene.geometry:
			if frame.semi_alpha_pixels > 0 or frame.opaque_pixels == 0 or mini(mini(frame.margin_left,frame.margin_right),mini(frame.margin_top,frame.margin_bottom)) < 1:
				failures += 1
		reports[state] = scene.geometry.duplicate(true)
		for i in range(3):
			await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		assert(image.get_size() == Vector2i(1280,720))
		assert(image.save_png("res://docs/screenshots/art-r001-down-%s-source-review.png" % state) == OK)
	var file := FileAccess.open("res://art/rnd/art_r001/review/down-source-frame-geometry.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"scope":"down only; not complete four-direction contract","source_fps":7,"normalized_comparison_duration_ms":150,"failures":failures,"states":reports},"\t")+"\n")
	print("Native down source: 10 complete cells measured; geometry/alpha failures=" + str(failures))
	scene.free()
	quit(1 if failures > 0 else 0)
