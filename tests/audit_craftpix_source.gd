extends SceneTree

const BASE := "res://art/vendor/craftpix/"

func _initialize() -> void:
	var report := {"source_tmx": {}, "images": {}}
	for relative in ["main_character/male/Base_boy.tmx", "fauna/hunt_animal/Animals.tmx", "tile/path_and_road/Roads.tmx"]:
		report.source_tmx[relative] = read_tmx(BASE + relative)
	for folder in ["main_character/male", "fauna/hunt_animal", "flora/tree", "tile/path_and_road"]:
		for filename in DirAccess.get_files_at(BASE + folder):
			if not filename.ends_with(".png"):
				continue
			var path: String = BASE + folder + "/" + filename
			var img := Image.new()
			assert(img.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK)
			assert(img != null, path)
			var info := {"size": [img.get_width(), img.get_height()], "sha256": FileAccess.get_sha256(path)}
			var cell := 64 if folder.begins_with("main_character") else 32
			if folder.begins_with("main_character") or filename.begins_with("Boar_"):
				info.frames = []
				for row in range(img.get_height() / cell):
					for column in range(img.get_width() / cell):
						var region := img.get_region(Rect2i(column * cell, row * cell, cell, cell))
						var bounds := alpha_bounds(region)
						info.frames.append({"row": row, "frame": column, "bbox": bounds,
							"feet_last_y": bounds[1] + bounds[3] - 1,
							"center_x": bounds[0] + bounds[2] / 2.0})
			else:
				info.bbox = alpha_bounds(img)
			report.images[folder + "/" + filename] = info
	var file := FileAccess.open("res://data/source_mapping/craftpix_audit.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("Craftpix audit: %d original PNGs measured; TMX geometry/timelines recorded." % report.images.size())
	quit()

func alpha_bounds(img: Image) -> Array:
	var min_point := Vector2i(img.get_width(), img.get_height())
	var max_point := Vector2i(-1, -1)
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a > 0.01:
				min_point = min_point.min(Vector2i(x, y))
				max_point = max_point.max(Vector2i(x, y))
	if max_point.x < 0:
		return [0, 0, 0, 0]
	return [min_point.x, min_point.y, max_point.x - min_point.x + 1, max_point.y - min_point.y + 1]

func read_tmx(path: String) -> Dictionary:
	var parser := XMLParser.new()
	assert(parser.open(path) == OK)
	var result := {"sha256": FileAccess.get_sha256(path), "tilesets": []}
	var current := {}
	var sequence := []
	while parser.read() == OK:
		var name := parser.get_node_name() if parser.get_node_type() in [XMLParser.NODE_ELEMENT, XMLParser.NODE_ELEMENT_END] else ""
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			if name == "map":
				result.tile_size = [int(parser.get_named_attribute_value("tilewidth")), int(parser.get_named_attribute_value("tileheight"))]
			elif name == "tileset":
				current = {"name": parser.get_named_attribute_value("name"), "columns": int(parser.get_named_attribute_value("columns")), "sequences": []}
			elif name == "image":
				current.source = parser.get_named_attribute_value("source")
				current.size = [int(parser.get_named_attribute_value("width")), int(parser.get_named_attribute_value("height"))]
			elif name == "animation":
				sequence = []
			elif name == "frame":
				sequence.append({"tile_id": int(parser.get_named_attribute_value("tileid")), "duration_ms": int(parser.get_named_attribute_value("duration"))})
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			if name == "animation":
				current.sequences.append(sequence)
			elif name == "tileset":
				result.tilesets.append(current)
	for tileset: Dictionary in result.tilesets:
		if not tileset.has("size") or tileset.sequences.is_empty():
			continue
		if path.contains("Base_boy") and int(tileset.size[1]) != 256:
			# Helper shadow strips are not full 64x64 character atlases.
			tileset.erase("sequences")
			continue
		var cell := 64 if path.contains("Base_boy") else 32
		var cells: Dictionary = {}
		for tiles: Array in tileset.sequences:
			var first_id: int = tiles[0].tile_id
			var row: int = (first_id / int(tileset.columns)) / (cell / 16)
			var key := str(row)
			var logical := {"columns": [], "durations_ms": []}
			for tile: Dictionary in tiles:
				logical.columns.append((int(tile.tile_id) % int(tileset.columns)) / (cell / 16))
				logical.durations_ms.append(tile.duration_ms)
			if cells.has(key):
				assert(cells[key] == logical, "TMX subtiles disagree: " + str(tileset.source))
			else:
				cells[key] = logical
		tileset.logical_sequences = cells
		tileset.verified_subtile_sequences = tileset.sequences.size()
		tileset.erase("sequences")
	return result
