extends Node2D

const SOURCES := preload("res://data/source_mapping/craftpix.json")
const GROUND := preload("res://art/vendor/craftpix/tile/path_and_road/Ground_grass.png")
const ROAD := preload("res://art/vendor/craftpix/tile/path_and_road/Road1_grass.png")

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tiles := TileSet.new()
	var source_size: int = SOURCES.data.world.source_tile_size
	tiles.tile_size = Vector2i.ONE * source_size
	var grass := TileSetAtlasSource.new()
	grass.texture = GROUND
	grass.texture_region_size = Vector2i.ONE * source_size
	var grass_tile := Vector2i(SOURCES.data.world.ground_tile[0], SOURCES.data.world.ground_tile[1])
	grass.create_tile(grass_tile)
	tiles.add_source(grass, 0)
	var road := TileSetAtlasSource.new()
	road.texture = ROAD
	road.texture_region_size = Vector2i.ONE * source_size
	var road_origin := Vector2i(SOURCES.data.world.road_patch.atlas_origin[0], SOURCES.data.world.road_patch.atlas_origin[1])
	for y in range(5):
		for x in range(5):
			road.create_tile(road_origin + Vector2i(x, y))
	tiles.add_source(road, 1)
	var ground_layer := TileMapLayer.new()
	ground_layer.name = "Ground16"
	ground_layer.tile_set = tiles
	add_child(ground_layer)
	move_child(ground_layer, 0)
	for y in range(40):
		for x in range(60):
			ground_layer.set_cell(Vector2i(x, y), 0, grass_tile)
	var road_layer := TileMapLayer.new()
	road_layer.name = "RoadPatch16"
	road_layer.tile_set = tiles
	add_child(road_layer)
	move_child(road_layer, 1)
	# Native 80x176 road: extend the audited center row; preserve original end caps.
	var source_rows: Array = SOURCES.data.world.road_patch.source_rows
	for y in range(source_rows.size()):
		for x in range(5):
			road_layer.set_cell(Vector2i(28 + x, 16 + y), 1, road_origin + Vector2i(x, int(source_rows[y])))
	var footprints := Node2D.new()
	footprints.name = "FootprintGuides"
	footprints.set_script(load("res://scenes/dev/footprint_guides.gd"))
	footprints.z_index = 10
	add_child(footprints)
