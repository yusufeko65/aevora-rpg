extends RefCounted

## Narrow, read-only Exterior.tmx reader. Original CSV coordinates/GIDs survive unchanged.
static func read_source(path: String) -> Dictionary:
	var parser := XMLParser.new()
	assert(parser.open(path) == OK, "Missing original home TMX: " + path)
	var result := {"tilesets": [], "layers": []}
	var tileset: Dictionary = {}
	var layer: Dictionary = {}
	var chunk: Dictionary = {}
	while parser.read() == OK:
		var type := parser.get_node_type()
		var name := parser.get_node_name() if type in [XMLParser.NODE_ELEMENT, XMLParser.NODE_ELEMENT_END] else ""
		if type == XMLParser.NODE_ELEMENT:
			match name:
				"map":
					assert(parser.get_named_attribute_value("tilewidth") == "16" and parser.get_named_attribute_value("tileheight") == "16")
				"tileset":
					tileset = {"firstgid": int(parser.get_named_attribute_value("firstgid")), "columns": int(parser.get_named_attribute_value("columns"))}
				"image":
					tileset.file = path.get_base_dir() + "/" + parser.get_named_attribute_value("source")
					tileset.size = Vector2i(int(parser.get_named_attribute_value("width")), int(parser.get_named_attribute_value("height")))
				"layer":
					layer = {"id": int(parser.get_named_attribute_value("id")), "name": parser.get_named_attribute_value("name"), "cells": []}
				"data":
					assert(parser.get_named_attribute_value("encoding") == "csv", "Only original uncompressed Exterior CSV is supported")
				"chunk":
					chunk = {"x": int(parser.get_named_attribute_value("x")), "y": int(parser.get_named_attribute_value("y")), "width": int(parser.get_named_attribute_value("width")), "csv": ""}
		elif type == XMLParser.NODE_TEXT and not chunk.is_empty():
			chunk.csv += parser.get_node_data()
		elif type == XMLParser.NODE_ELEMENT_END:
			match name:
				"tileset":
					result.tilesets.append(tileset)
				"chunk":
					var values: PackedStringArray = str(chunk.csv).strip_edges().split(",", false)
					for i in range(values.size()):
						var gid := int(values[i].strip_edges())
						if gid != 0:
							layer.cells.append({"at": Vector2i(int(chunk.x) + i % int(chunk.width), int(chunk.y) + i / int(chunk.width)), "gid": gid})
					chunk = {}
				"layer":
					result.layers.append(layer)
	return result

static func resolve(gid_with_flags: int, tilesets: Array) -> Dictionary:
	var gid := gid_with_flags & 0x0fffffff
	var selected: Dictionary = {}
	for tileset: Dictionary in tilesets:
		if gid >= int(tileset.firstgid):
			selected = tileset
	assert(not selected.is_empty())
	var local := gid - int(selected.firstgid)
	return {"file": selected.file, "region": Rect2i(local % int(selected.columns) * 16, local / int(selected.columns) * 16, 16, 16), "flags": gid_with_flags & 0xf0000000}
