extends SceneTree

const HOME := preload("res://scenes/world/home_source.gd")

func _initialize() -> void:
	var source := HOME.read_source("res://art/vendor/craftpix/main_character/home/Exterior.tmx")
	for gid in [802, 803, 804, 819, 821, 836, 837, 838, 788, 789]:
		var tile := HOME.resolve(gid, source.tilesets)
		var image := Image.new()
		assert(image.load_png_from_buffer(FileAccess.get_file_as_bytes(tile.file)) == OK)
		var region := image.get_region(tile.region)
		var rows: Array = []
		for y in range(16):
			var pixels := ""
			for x in range(16):
				var color := region.get_pixel(x, y)
				pixels += ".. " if color.a < 0.01 else color.to_html(false).substr(0, 2) + " "
			rows.append(pixels)
		print(JSON.stringify({"gid": gid, "region": str(tile.region), "bounds": str(region.get_used_rect()), "rows_red_hex": rows}))
	quit()
