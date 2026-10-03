extends SceneTree

const HOME := preload("res://scenes/world/home_source.gd")

func _initialize() -> void:
	var source := HOME.read_source("res://art/vendor/craftpix/main_character/home/Exterior.tmx")
	for gid in [1014, 1056, 1057, 1064, 1065, 1066, 1067, 1068, 1081, 1082, 1083]:
		var tile := HOME.resolve(gid, source.tilesets)
		var image := Image.new()
		assert(image.load_png_from_buffer(FileAccess.get_file_as_bytes(tile.file)) == OK)
		var region := image.get_region(tile.region)
		var colors: Dictionary = {}
		var opaque := 0
		for y in range(16):
			for x in range(16):
				var color := region.get_pixel(x, y)
				var key := color.to_html()
				colors[key] = int(colors.get(key, 0)) + 1
				if color.a == 1:
					opaque += 1
		print(JSON.stringify({"gid":gid,"region":str(tile.region),"opaque":opaque,"colors":colors}))
	quit()
