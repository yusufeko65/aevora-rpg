extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func save_native(scene: Node2D, filename: String) -> Dictionary:
	scene.queue_redraw()
	for i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var scale := root.get_stretch_transform().get_scale()
	if image.get_size() != Vector2i(1280,720) or root.content_scale_size != Vector2i(640,360) or not scale.is_equal_approx(Vector2(2,2)):
		push_error("Native1280x720/logical640x360/exact2x capture required")
		return {}
	if image.save_png("res://docs/screenshots/"+filename) != OK:
		return {}
	return {"file":filename,"window":[1280,720],"logical":[640,360],"stretch":[2,2],"candidate_status":scene.validation.status,"preview_mode":scene.candidate_preview_mode(),"state":scene.state,"direction":scene.direction,"elapsed":scene.elapsed,"method":"actual displayed root Window framebuffer; no image resizing","root_guides":scene.root_guides,"canvas_guides":scene.canvas_guides}

func capture() -> void:
	root.content_scale_size = Vector2i(640,360)
	root.size = Vector2i(1280,720)
	var scene: Node2D = load("res://scenes/dev/art_r001_character_comparison.tscn").instantiate()
	root.add_child(scene)
	scene.set_process(false)
	scene.paused = true
	for i in range(8):
		await process_frame
	DisplayServer.window_set_size(Vector2i(1280,720),root.get_window_id())
	scene.root_guides = false
	scene.canvas_guides = false
	var evidence: Array = [await save_native(scene,"art-r001-godot-comparison.png")]
	scene.root_guides = true
	scene.canvas_guides = true
	if scene.textures.get("master_down") != null:
		scene.preview_native_sources = false
		evidence.append(await save_native(scene,"art-r001-master.png"))
		scene.preview_native_sources = true
	scene.state = "walk"
	scene.direction = "left" if scene.validation.status == "PASS" else "down"
	scene.elapsed = 0.3
	evidence.append(await save_native(scene,"art-r001-root-guides.png"))
	for item: Dictionary in evidence:
		if item.is_empty():
			scene.free()
			quit(1)
			return
	var file := FileAccess.open("res://art/rnd/art_r001/review/display-evidence.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(evidence,"\t")+"\n")
	print("ART-R001 captured %d native comparison/master frames; candidate %s" % [evidence.size(),scene.validation.status])
	scene.free()
	quit()
