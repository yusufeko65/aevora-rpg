extends SceneTree

const Contract = preload("res://systems/art_r001/asset_contract.gd")
var checks := 0
var errors: Array[String] = []
var missing: Array[String] = []

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		errors.append(message)

func digest(bytes: PackedByteArray) -> String:
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	return hash.finish().hex_encode()

func _initialize() -> void:
	var manifest := Contract.read_json("res://art/rnd/art_r001/metadata/source_frames.json")
	check(manifest.get("source_fps") == 7,"Preserve7FPS source timing")
	var results := {}
	for direction: String in Contract.DIRECTIONS:
		results[direction] = {}
		var master_path := "res://art/rnd/art_r001/candidates/sprite_studio/master_%s.png" % direction
		check(FileAccess.file_exists(master_path),"Missing master "+direction)
		for state: String in ["idle","walk"]:
			var count := 4 if state == "idle" else 6
			var paths: Array = manifest.get("frames",{}).get(direction,{}).get(state,[])
			check(paths.size() == count,"Source count "+direction+"/"+state)
			var frames: Array = []
			var distinct := {}
			for index in range(paths.size()):
				var path: String = paths[index]
				if not FileAccess.file_exists(path):
					missing.append(path)
					continue
				var image := Image.new()
				var decoded := image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK
				check(decoded and image.get_size() == Vector2i(64,64),path+":64px PNG required")
				if not decoded or image.get_size() != Vector2i(64,64):
					continue
				var cell := Contract.measure_cell(image,Vector2i.ZERO)
				check(cell.opaque_pixels > 0 and cell.transparent_pixels > 0 and cell.semi_alpha_pixels == 0,path+":hard-alpha content")
				check(mini(mini(cell.margin_left,cell.margin_right),mini(cell.margin_top,cell.margin_bottom)) > 0,path+":clear border")
				cell["path"] = path
				cell["frame"] = index
				cell["file_sha256"] = digest(FileAccess.get_file_as_bytes(path))
				cell["pixel_sha256"] = digest(image.get_data())
				distinct[cell.pixel_sha256] = true
				frames.append(cell)
			if frames.size() == count:
				check(distinct.size() == count,direction+"/"+state+":static/duplicate placeholders")
			var rig_path := "res://art/rnd/art_r001/candidates/sprite_studio/rigs/art-r001-%s-%s.json" % [direction,state]
			if not FileAccess.file_exists(rig_path):
				missing.append(rig_path)
			else:
				var rig := Contract.read_json(rig_path)
				check(rig.get("rigVersion") == 3 and rig.get("fps") == 7 and rig.get("looping") == true,rig_path+":v3/fps/loop")
				check(rig.get("rootMotion") == "in-place",rig_path+":in-place root")
				check(rig.get("frames",[]).size() == count,rig_path+":pose count")
				check(rig.get("masterHash","").to_lower() == digest(FileAccess.get_file_as_bytes(master_path)),rig_path+":immutable source hash")
				for pose: Dictionary in rig.get("frames",[]):
					check(pose.get("root",{}).get("dx",0) == 0 and pose.get("root",{}).get("dy",0) == 0,rig_path+":no world-root translation")
			results[direction][state] = {"frames":frames,"distinct_frames":distinct.size(),"rig":rig_path}
	var status := "FAIL" if not errors.is_empty() else ("BLOCKED" if not missing.is_empty() else "PASS")
	var report := {"status":status,"checks":checks,"errors":errors,"missing":missing,"source_fps":7,"normalized_duration_ms":150,"pivot":[32,44],"measurement_policy":"read-only; physical sole offsets and moving centroid never recenter frames","directions":results}
	var file := FileAccess.open("res://art/rnd/art_r001/review/source-contract-report.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")+"\n")
	print("ART-R001 source contract: "+status+"; checks="+str(checks)+"; missing="+str(missing.size())+"; errors="+str(errors.size()))
	for error: String in errors:
		push_error(error)
	quit(1 if status == "FAIL" else (2 if status == "BLOCKED" else 0))
