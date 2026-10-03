extends Node2D

## Source tiles are drawn at native 16px size, not cropped into new vendor images.
const HOME_SOURCE := preload("res://scenes/world/home_source.gd")
var cells: Array = []
var tilesets: Array = []
var source_offset := Vector2.ZERO
var textures: Dictionary = {}

func _draw() -> void:
	for cell: Dictionary in cells:
		var tile := HOME_SOURCE.resolve(int(cell.gid), tilesets)
		assert(FileAccess.file_exists(tile.file), "Required Exterior asset missing: " + str(tile.file).get_file())
		assert((int(tile.flags) & 0x30000000) == 0, "Unsupported diagonal/hexagonal source tile; stop rather than guess")
		if not textures.has(tile.file):
			textures[tile.file] = load(tile.file) as Texture2D
		assert(Rect2i(Vector2i.ZERO, textures[tile.file].get_size()).encloses(tile.region))
		var flip := Vector2(-1 if int(tile.flags) & 0x80000000 else 1, -1 if int(tile.flags) & 0x40000000 else 1)
		draw_set_transform(Vector2(cell.at) * 16 + source_offset + Vector2(8, 8), 0, flip)
		draw_texture_rect_region(textures[tile.file], Rect2(-8, -8, 16, 16), Rect2(tile.region))
	draw_set_transform(Vector2.ZERO)
