extends SceneTree

## Reproduce the vendor Right/step-0 anomaly before the full-source-derived override.
## Runtime coverage for all 32 corrected poses lives in dev_r001_1_test.gd.
const DATA := preload("res://data/source_mapping/craftpix.json")

func _initialize() -> void:
	var attack: Dictionary = DATA.data.human.states.attack
	var originals: Array[Image] = []
	for layer: Dictionary in attack.sword_layers:
		var img := Image.new()
		assert(img.load_png_from_buffer(FileAccess.get_file_as_bytes(layer.file)) == OK)
		originals.append(img.get_region(Rect2i(0, 128, 64, 64)))
	var full := Image.new()
	assert(full.load_png_from_buffer(FileAccess.get_file_as_bytes(attack.sword_full.file)) == OK)
	var expected := full.get_region(Rect2i(0, 128, 64, 64))
	var composition := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	composition.fill(Color.TRANSPARENT)
	for img in originals:
		composition.blend_rect(img, Rect2i(0, 0, 64, 64), Vector2i.ZERO)
	var differences: Array = []
	for y in range(64):
		for x in range(64):
			var a := composition.get_pixel(x, y)
			var b := expected.get_pixel(x, y)
			if a.a > 0.01 and maxf(absf(a.r-b.r), maxf(absf(a.g-b.g), absf(a.b-b.b))) > 1.01/255.0:
				var layers: Array = []
				for i in range(5):
					var pixel := originals[i].get_pixel(x, y)
					if pixel.a > 0:
						layers.append([attack.sword_layers[i].file.get_file(), pixel.to_html()])
				differences.append({"at":[x,y],"composite":a.to_html(),"full":b.to_html(),"layers":layers})
	print(JSON.stringify(differences))
	quit()
