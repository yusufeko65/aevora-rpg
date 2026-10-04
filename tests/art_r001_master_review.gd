extends SceneTree

const Contract = preload("res://systems/art_r001/asset_contract.gd")

func _initialize() -> void:
	var all_results := {}
	var failures := 0
	for direction: String in ["down","left","right","up"]:
		var path := "res://art/rnd/art_r001/candidates/sprite_studio/master_%s.png" % direction
		var image := Image.new()
		if not FileAccess.file_exists(path) or image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK or image.get_size() != Vector2i(64,64):
			failures += 1
			all_results[direction] = {"error":"Missing or invalid 64x64 master", "source":path}
			continue
		var geometry := Contract.measure_cell(image,Vector2i.ZERO)
		geometry["source"] = path
		geometry["dimensions"] = [64,64]
		geometry["review_target_pivot"] = [32,44]
		geometry["root_review"] = "Bottom pixel is evidence, not an auto-alignment instruction. Directional feet/root review required."
		all_results[direction] = geometry
		if geometry.opaque_pixels == 0 or geometry.semi_alpha_pixels > 0 or geometry.transparent_pixels == 0 or mini(mini(geometry.margin_left,geometry.margin_right),mini(geometry.margin_top,geometry.margin_bottom)) < 1:
			failures += 1
	var output := FileAccess.open("res://art/rnd/art_r001/review/direction-master-geometry.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"failures":failures,"directions":all_results},"\t")+"\n")
	print(JSON.stringify(all_results))
	quit(1 if failures > 0 else 0)

func review_single_master() -> void:
	var path := OS.get_environment("ART_R001_MASTER_PATH")
	var image := Image.new()
	if not FileAccess.file_exists(path) or image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK or image.get_size() != Vector2i(64,64):
		push_error("Master must decode as exact 64x64 PNG")
		quit(1)
		return
	var geometry := Contract.measure_cell(image,Vector2i.ZERO)
	geometry["source"] = path
	geometry["dimensions"] = [64,64]
	geometry["review_target_pivot"] = [32,44]
	geometry["root_review"] = "Bottom pixel is evidence, not an auto-alignment instruction. Visual feet/root review required."
	var file := FileAccess.open("res://art/rnd/art_r001/review/master-geometry.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(geometry,"\t")+"\n")
	print(JSON.stringify(geometry))
	quit(1 if geometry.opaque_pixels == 0 or geometry.semi_alpha_pixels > 0 or geometry.transparent_pixels == 0 else 0)
