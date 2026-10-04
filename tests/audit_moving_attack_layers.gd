extends SceneTree

const DATA := preload("res://data/source_mapping/craftpix.json")
var images: Dictionary = {}

func image(path: String) -> Image:
	if not images.has(path):
		var img := Image.new()
		assert(img.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK)
		images[path] = img
	return images[path]

func differences(a: Image, b: Image) -> int:
	if a.get_data() == b.get_data():
		return 0
	var count := 0
	for y in range(64):
		for x in range(64):
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			if absf(ca.a - cb.a) > 1.01 / 255.0 or (ca.a > 0.01 and maxf(absf(ca.r-cb.r), maxf(absf(ca.g-cb.g), absf(ca.b-cb.b))) > 1.01 / 255.0):
				count += 1
	return count

func permutations(values: Array) -> Array:
	if values.is_empty():
		return [[]]
	var result: Array = []
	for value in values:
		var rest := values.duplicate()
		rest.erase(value)
		for tail: Array in permutations(rest):
			result.append([value] + tail)
	return result

func composite(pose: Dictionary, row: int, step: int, order: Array, shadow: bool) -> Image:
	var result := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	result.fill(Color.TRANSPARENT)
	var layers: Array = [pose.shadow] if shadow else []
	for index in order:
		layers.append(pose.sword_layers[index])
	for layer: Dictionary in layers:
		var column: int = layer.source_columns[str(row)].columns[step]
		result.blend_rect(image(layer.file), Rect2i(column*64,row*64,64,64), Vector2i.ZERO)
	return result

func _initialize() -> void:
	var audit: Array = []
	for state: String in ["walk_attack", "run_attack"]:
		var pose: Dictionary = DATA.data.human.states[state]
		for row in range(4):
			for step in range(int(pose.frame_count)):
				var expected := image(pose.sword_full.file).get_region(Rect2i(step*64,row*64,64,64))
				var order: Array = [0,1,2,3,4]
				var original := differences(composite(pose,row,step,order,false),expected)
				if original > 0:
					for candidate: Array in permutations([0,1,2,3,4]):
						if differences(composite(pose,row,step,candidate,false),expected) == 0:
							order = candidate
							break
				var shadow_expected := image(pose.sword_full_with_shadow.file).get_region(Rect2i(step*64,row*64,64,64))
				audit.append({"state":state,"row":row,"step":step,"original_differences":original,"order":order,"resolved_differences":differences(composite(pose,row,step,order,false),expected),"shadow_differences":differences(composite(pose,row,step,order,true),shadow_expected)})
	print(JSON.stringify(audit))
	quit()
