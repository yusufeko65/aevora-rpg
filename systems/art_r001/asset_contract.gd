extends RefCounted

const META := "res://art/rnd/art_r001/metadata/aevora_base_human_v0.json"
const DIRECTIONS := ["down", "left", "right", "up"]

static func read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}

static func metadata_errors(meta: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if meta.get("id") != "ARTCHAR-R001" or meta.get("status") != "rnd_candidate":
		errors.append("Candidate identity/status must not overwrite CHAR-001")
	var frame_size: Variant = meta.get("frame_size", [])
	if meta.get("slug") != "aevora_base_human_v0" or not frame_size is Array or frame_size.size() != 2:
		errors.append("Slug/frame_size must declare the fixed 64x64 contract")
	elif frame_size[0] != 64 or frame_size[1] != 64:
		errors.append("Frame size must be exactly 64x64")
	var pivot: Variant = meta.get("pivot", [])
	if not pivot is Array or pivot.size() != 2:
		errors.append("Pivot must be an explicit [x,y] array")
	elif not (pivot[0] is float or pivot[0] is int) or not (pivot[1] is float or pivot[1] is int):
		errors.append("Pivot must be numeric")
	elif pivot[0] < 0 or pivot[0] >= 64 or pivot[1] < 0 or pivot[1] >= 64:
		errors.append("Pivot must be inside the frame")
	elif pivot[0] != 32 or pivot[1] != 44:
		errors.append("Changed comparison pivot requires review, not silent normalization")
	var rows: Variant = meta.get("direction_rows", {})
	if not rows is Dictionary or rows.size() != 4:
		errors.append("All four explicit ART-R001 direction rows required")
	else:
		for index in range(4):
			if rows.get(DIRECTIONS[index],-1) != index:
				errors.append("Wrong direction row: " + DIRECTIONS[index])
	var states: Variant = meta.get("states", {})
	if not states is Dictionary or states.size() != 2:
		errors.append("Exactly Idle and Walk required")
		return errors
	for state: String in ["idle", "walk"]:
		var spec: Variant = states.get(state, {})
		if not spec is Dictionary:
			errors.append(state + ": invalid state declaration")
			continue
		if spec.get("frames") != (4 if state == "idle" else 6):
			errors.append(state + ": wrong frame count")
		if spec.get("duration_ms") != 150 or spec.get("loop") != true:
			errors.append(state + ": explicit looping 150ms timing required")
		var path: Variant = spec.get("file", "")
		if not path is String or not path.begins_with("res://art/rnd/art_r001/exports/") or not path.ends_with(".png") or ".." in path:
			errors.append(state + ": invalid normalized PNG path")
	for field: String in ["brief", "provenance"]:
		var path: Variant = meta.get(field, "")
		if not path is String or not path.begins_with("res://art/rnd/art_r001/") or ".." in path or not FileAccess.file_exists(path):
			errors.append(field + ": metadata source path missing/invalid")
	var provenance_path: Variant = meta.get("provenance", "")
	if provenance_path is String and FileAccess.file_exists(provenance_path):
		var provenance := read_json(provenance_path)
		var prompt: Variant = provenance.get("exact_character_prompt", "")
		if provenance.get("id") != "ARTCHAR-R001" or not prompt is String or prompt.is_empty():
			errors.append("Provenance JSON must preserve identity and exact original prompt")
		if provenance.get("tool_commit") != meta.get("tool_commit"):
			errors.append("Provenance/tool commit mismatch")
	for field: String in ["tool", "tool_version", "tool_commit", "source_workflow", "provider", "model", "generation_date", "source_master_paths", "normalization_notes"]:
		if not meta.has(field):
			errors.append("Provenance declaration missing: " + field)
	var masters: Variant = meta.get("source_master_paths", [])
	if not masters is Array:
		errors.append("source_master_paths must be an array")
	else:
		for path: Variant in masters:
			if not path is String or not path.begins_with("res://art/rnd/art_r001/candidates/") or ".." in path or not FileAccess.file_exists(path):
				errors.append("Invalid/missing original master path")
	return errors

# Read-only cell measurements: these must never drive automatic alignment.
static func measure_cell(image: Image, origin: Vector2i) -> Dictionary:
	var minimum := Vector2i(64,64)
	var maximum := Vector2i(-1,-1)
	var semi := 0
	var transparent := 0
	var opaque := 0
	var sum_x := 0
	var sum_y := 0
	var palette := {}
	for y in range(64):
		for x in range(64):
			var alpha := roundi(image.get_pixel(origin.x+x, origin.y+y).a * 255)
			if alpha == 0:
				transparent += 1
				continue
			if alpha != 255:
				semi += 1
			opaque += 1
			sum_x += x
			sum_y += y
			palette[image.get_pixel(origin.x+x,origin.y+y).to_rgba32()] = true
			minimum.x = mini(minimum.x,x)
			minimum.y = mini(minimum.y,y)
			maximum.x = maxi(maximum.x,x)
			maximum.y = maxi(maximum.y,y)
	var populated := opaque > 0
	return {
		"bbox": [minimum.x,minimum.y,maximum.x-minimum.x+1,maximum.y-minimum.y+1] if populated else null,
		"visible_width": maximum.x-minimum.x+1 if populated else 0,
		"visible_height": maximum.y-minimum.y+1 if populated else 0,
		"bottommost_opaque_y": maximum.y if populated else null,
		"margin_left": minimum.x if populated else 64,
		"margin_right": 63-maximum.x if populated else 64,
		"margin_top": minimum.y if populated else 64,
		"margin_bottom": 63-maximum.y if populated else 64,
		"opaque_pixels": opaque, "transparent_pixels": transparent, "semi_alpha_pixels": semi,
		"opaque_centroid": [float(sum_x)/opaque,float(sum_y)/opaque] if populated else null,
		"unique_visible_colors": palette.size(),
		"bottom_delta_from_target_root": maximum.y-44 if populated else null
	}

static func inspect_sheet(image: Image, frames: int) -> Dictionary:
	var errors: Array[String] = []
	var cells: Array = []
	if image.is_empty() or image.get_size() != Vector2i(64*frames,256):
		return {"errors":["Wrong sheet dimensions/padding: expected %dx256" % (64*frames)],"cells":cells}
	for row in range(4):
		for frame in range(frames):
			var cell := measure_cell(image,Vector2i(frame*64,row*64))
			cell["direction"] = DIRECTIONS[row]
			cell["frame"] = frame
			cells.append(cell)
			var label := "%s frame %d" % [DIRECTIONS[row],frame]
			if cell.opaque_pixels == 0:
				errors.append(label + ": empty cell (wrong count/row or padding)")
			if cell.transparent_pixels == 0:
				errors.append(label + ": no transparent background")
			if cell.semi_alpha_pixels > 0:
				errors.append(label + ": pixel-unsafe semitransparent alpha")
			if mini(mini(cell.margin_left,cell.margin_right),mini(cell.margin_top,cell.margin_bottom)) < 1:
				errors.append(label + ": ink reaches cell edge; unsafe margin/canvas clipping")
	return {"errors":errors,"cells":cells,"dimensions":[image.get_width(),image.get_height()]}

static func validate(meta: Dictionary) -> Dictionary:
	var errors := metadata_errors(meta)
	var missing: Array[String] = []
	var sheets := {}
	if errors.is_empty():
		for state: String in ["idle", "walk"]:
			var spec: Dictionary = meta.states[state]
			if not FileAccess.file_exists(spec.file):
				missing.append(spec.file)
				continue
			var image := Image.new()
			if image.load_png_from_buffer(FileAccess.get_file_as_bytes(spec.file)) != OK:
				errors.append(state + ": PNG failed to decode")
				continue
			var report := inspect_sheet(image,int(spec.frames))
			sheets[state] = report
			for error: String in report.errors:
				errors.append(state + ": " + error)
	if missing.is_empty() and errors.is_empty():
		if meta.get("generation_status") != "generated" or meta.get("source_master_paths",[]).is_empty():
			errors.append("Existing sheets need generated status and preserved original master provenance")
		if meta.get("model") == null or meta.get("generation_date") == null:
			errors.append("Real generation needs actual model/date provenance (explicit unavailable model allowed)")
	return {
		"candidate":"ARTCHAR-R001", "status":"FAIL" if not errors.is_empty() else ("BLOCKED" if not missing.is_empty() else "PASS"),
		"errors":errors,"missing_outputs":missing,"pivot":meta.get("pivot"),"sheets":sheets,
		"measurement_policy":"read-only; no bbox recentering/rescale; bottom pixel is not a physical root measurement",
		"commercial_approval":false
	}
