class_name CharacterVisualManifest
extends RefCounted

const REQUIRED_STATES := ["idle", "walk", "run", "attack", "hurt", "dead", "tool"]
const REQUIRED_DIRECTIONS := ["down", "up", "left", "right"]
const REQUIRED_LAYERS := ["body", "hair", "outfit"]


static func load_and_validate(path: String, check_files := true) -> Dictionary:
	var result := {"ok": false, "data": {}, "errors": PackedStringArray()}
	if not FileAccess.file_exists(path):
		result.errors.append("Manifest does not exist: %s" % path)
		return result
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		result.errors.append("Manifest root must be a JSON object")
		return result
	result.data = parsed
	result.errors = validate_data(parsed, check_files)
	result.ok = result.errors.is_empty()
	return result


static func validate_data(data: Dictionary, check_files := true) -> PackedStringArray:
	var errors := PackedStringArray()
	if data.get("schema_version", 0) != 1:
		errors.append("schema_version must be 1")
	if String(data.get("visual_id", "")).is_empty():
		errors.append("visual_id is required")
	var canvas = data.get("canvas", {})
	var width := int(canvas.get("width", 0))
	var height := int(canvas.get("height", 0))
	if width < 64 or height < 64:
		errors.append("canvas must be at least 64x64")
	var anchor = data.get("anchor", {})
	var anchor_x := int(anchor.get("x", -1))
	var anchor_y := int(anchor.get("y", -1))
	if anchor_x < 0 or anchor_y < 0 or anchor_x >= width or anchor_y >= height:
		errors.append("anchor must lie inside the declared canvas")
	var directions: Array = data.get("directions", [])
	for direction in REQUIRED_DIRECTIONS:
		if direction not in directions:
			errors.append("missing required direction: %s" % direction)
	var layers: Dictionary = data.get("layers", {})
	for layer in REQUIRED_LAYERS:
		if not layers.has(layer):
			errors.append("missing required visual layer: %s" % layer)
	var animations: Dictionary = data.get("animations", {})
	for state in REQUIRED_STATES:
		if not animations.has(state):
			errors.append("missing required animation: %s" % state)
			continue
		_validate_animation(state, animations[state], directions, layers, Vector2i(width, height), check_files, errors)
	return errors


static func _validate_animation(state: String, animation: Dictionary, directions: Array, layers: Dictionary, canvas: Vector2i, check_files: bool, errors: PackedStringArray) -> void:
	var frame_count := int(animation.get("frame_count", 0))
	if frame_count <= 0:
		errors.append("%s frame_count must be positive" % state)
	var durations: Array = animation.get("durations_ms", [])
	if durations.size() != frame_count:
		errors.append("%s durations_ms count must match frame_count" % state)
	for duration in durations:
		if int(duration) <= 0:
			errors.append("%s frame durations must be positive" % state)
	var rows: Dictionary = animation.get("direction_rows", {})
	var used_rows := {}
	for direction in REQUIRED_DIRECTIONS:
		if not rows.has(direction):
			errors.append("%s missing direction row: %s" % [state, direction])
			continue
		var row := int(rows[direction])
		if row < 0 or row >= directions.size():
			errors.append("%s direction row is outside atlas: %s" % [state, direction])
		if used_rows.has(row):
			errors.append("%s direction rows must be unique" % state)
		used_rows[row] = true
	var files: Dictionary = animation.get("layer_files", {})
	for layer_name in layers:
		var layer: Dictionary = layers[layer_name]
		if not bool(layer.get("visible_on_character", true)):
			continue
		if not files.has(layer_name):
			errors.append("%s missing file for visible layer %s" % [state, layer_name])
			continue
		if check_files:
			_validate_atlas(String(files[layer_name]), state, layer_name, frame_count, directions.size(), canvas, errors)


static func _validate_atlas(path: String, state: String, layer_name: String, frame_count: int, direction_count: int, canvas: Vector2i, errors: PackedStringArray) -> void:
	if path.get_extension().to_lower() != "png":
		errors.append("%s/%s must use PNG" % [state, layer_name])
		return
	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		errors.append("%s/%s file missing: %s" % [state, layer_name, path])
		return
	var image := Image.new()
	var load_error := image.load(absolute_path)
	if load_error != OK:
		errors.append("%s/%s PNG cannot be loaded" % [state, layer_name])
		return
	var expected := Vector2i(frame_count * canvas.x, direction_count * canvas.y)
	if image.get_size() != expected:
		errors.append("%s/%s atlas dimensions %s do not match expected %s" % [state, layer_name, image.get_size(), expected])
	if image.detect_alpha() == Image.ALPHA_NONE:
		errors.append("%s/%s has no usable alpha channel" % [state, layer_name])
		return
	var transparent_pixels := 0
	var semi_transparent_pixels := 0
	for y in image.get_height():
		for x in image.get_width():
			var alpha := image.get_pixel(x, y).a8
			if alpha == 0:
				transparent_pixels += 1
			elif alpha < 255:
				semi_transparent_pixels += 1
	if transparent_pixels == 0:
		errors.append("%s/%s has an accidental opaque full-frame background" % [state, layer_name])
	if semi_transparent_pixels > 0:
		errors.append("%s/%s contains semi-transparent core sprite pixels" % [state, layer_name])
	if image.get_size() == expected:
		for row in direction_count:
			for frame in frame_count:
				if not _cell_border_is_clear(image, Rect2i(frame * canvas.x, row * canvas.y, canvas.x, canvas.y)):
					errors.append("%s/%s has opaque pixels touching a frame boundary at row %d frame %d" % [state, layer_name, row, frame])


static func _cell_border_is_clear(image: Image, cell: Rect2i) -> bool:
	for x in range(cell.position.x, cell.end.x):
		if image.get_pixel(x, cell.position.y).a8 > 0 or image.get_pixel(x, cell.end.y - 1).a8 > 0:
			return false
	for y in range(cell.position.y, cell.end.y):
		if image.get_pixel(cell.position.x, y).a8 > 0 or image.get_pixel(cell.end.x - 1, y).a8 > 0:
			return false
	return true


static func validate_png_fixture(path: String, expected_size: Vector2i, require_hard_alpha := true) -> PackedStringArray:
	var errors := PackedStringArray()
	var image := Image.new()
	var load_error := image.load(ProjectSettings.globalize_path(path))
	if load_error != OK:
		errors.append("PNG cannot be loaded")
		return errors
	if image.get_size() != expected_size:
		errors.append("invalid atlas dimensions")
	if image.detect_alpha() == Image.ALPHA_NONE:
		errors.append("missing alpha channel")
	var transparent := false
	var semi_transparent := false
	for y in image.get_height():
		for x in image.get_width():
			var alpha := image.get_pixel(x, y).a8
			transparent = transparent or alpha == 0
			semi_transparent = semi_transparent or (alpha > 0 and alpha < 255)
	if not transparent:
		errors.append("opaque accidental background")
	if require_hard_alpha and semi_transparent:
		errors.append("semi-transparent fringe")
	return errors
