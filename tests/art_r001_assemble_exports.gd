extends SceneTree

const Contract = preload("res://systems/art_r001/asset_contract.gd")

func _initialize() -> void:
	var sources := Contract.read_json("res://art/rnd/art_r001/metadata/source_frames.json")
	var sheets := {}
	var errors: Array[String] = []
	var missing: Array[String] = []
	var hashes := {}
	for state: String in ["idle","walk"]:
		var frames := 4 if state == "idle" else 6
		var sheet := Image.create(64*frames,256,false,Image.FORMAT_RGBA8)
		sheet.fill(Color.TRANSPARENT)
		for row in range(4):
			var direction: String = Contract.DIRECTIONS[row]
			var paths: Array = sources.get("frames",{}).get(direction,{}).get(state,[])
			if paths.size() != frames:
				errors.append(direction+"/"+state+": wrong source count")
				continue
			for frame in range(frames):
				var path: String = paths[frame]
				if not FileAccess.file_exists(path):
					missing.append(path)
					continue
				var image := Image.new()
				if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK or image.get_size() != Vector2i(64,64):
					errors.append(path+": invalid PNG/fixed canvas")
					continue
				var before := image.get_data()
				# Copy the ENTIRE source canvas to its explicit row/column. No trim,
				# recenter, interpolation, rescaling, root correction or alpha edits.
				sheet.blit_rect(image,Rect2i(0,0,64,64),Vector2i(frame*64,row*64))
				var copied := sheet.get_region(Rect2i(frame*64,row*64,64,64))
				if before != copied.get_data():
					errors.append(path+": assembly changed pixels")
				var hasher := HashingContext.new()
				hasher.start(HashingContext.HASH_SHA256)
				hasher.update(before)
				hashes[path] = hasher.finish().hex_encode()
		sheets[state] = sheet
	var status := "FAIL" if not errors.is_empty() else ("BLOCKED" if not missing.is_empty() else "PASS")
	if status == "PASS":
		for state: String in ["idle","walk"]:
			if sheets[state].save_png("res://art/rnd/art_r001/exports/"+state+".png") != OK:
				errors.append("Cannot save normalized "+state)
				status = "FAIL"
	var file := FileAccess.open("res://art/rnd/art_r001/review/export-assembly.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"status":status,"errors":errors,"missing":missing,"source_pixel_hashes":hashes,"policy":"full64x64 cell blit only; no transformed pixels; timing is declared separately"},"\t")+"\n")
	print("ART-R001 fixed-grid assembly: "+status+"; missing="+str(missing.size()))
	quit(1 if status == "FAIL" else (2 if status == "BLOCKED" else 0))
