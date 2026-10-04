extends Node2D

const SOURCES := preload("res://data/source_mapping/craftpix.json")
const HOME_SOURCE := preload("res://scenes/world/home_source.gd")
const HOME_TILES := preload("res://scenes/world/home_tiles.gd")
var home_mapping: Dictionary

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	home_mapping = HOME_SOURCE.read_source(SOURCES.data.world.home.source_tmx)
	var base_grass := HOME_SOURCE.resolve(int(SOURCES.data.world.home.base_grass_gid), home_mapping.tilesets)
	var tiles := TileSet.new()
	var source_size: int = SOURCES.data.world.source_tile_size
	tiles.tile_size = Vector2i.ONE * source_size
	var grass := TileSetAtlasSource.new()
	grass.texture = load(base_grass.file)
	grass.texture_region_size = Vector2i.ONE * source_size
	var grass_tile: Vector2i = base_grass.region.position / source_size
	grass.create_tile(grass_tile)
	tiles.add_source(grass, 0)
	var ground_layer := TileMapLayer.new()
	ground_layer.name = "Ground16"
	ground_layer.tile_set = tiles
	add_child(ground_layer)
	move_child(ground_layer, 0)
	for y in range(40):
		for x in range(60):
			ground_layer.set_cell(Vector2i(x, y), 0, grass_tile)
	_build_home()
	var footprints := Node2D.new()
	footprints.name = "FootprintGuides"
	footprints.set_script(load("res://scenes/dev/footprint_guides.gd"))
	footprints.z_index = 10
	add_child(footprints)

func _build_home() -> void:
	var spec: Dictionary = SOURCES.data.world.home
	var terrain_ids := PackedInt32Array(spec.terrain_layer_ids)
	var house_ids := PackedInt32Array(spec.house_layer_ids)
	var offset := Vector2(spec.offset[0], spec.offset[1])
	var terrain := Node2D.new()
	terrain.name = "HomeTerrain"
	add_child(terrain)
	move_child(terrain, 1)
	var house := StaticBody2D.new()
	house.name = "House"
	house.collision_layer = 2 # Environment only; actors select it through their masks.
	var house_root := Vector2(spec.house_source_root[0], spec.house_source_root[1]) * 16
	house.position = offset + house_root
	get_node("Actors").add_child(house)
	_add_rectangle(house, Vector2(128, 40), Vector2(0, -20))
	for layer: Dictionary in home_mapping.layers:
		if terrain_ids.has(int(layer.id)):
			var visual := _tile_visual(layer.cells, offset)
			visual.name = str(layer.name) + "_" + str(layer.id)
			terrain.add_child(visual)
		elif house_ids.has(int(layer.id)):
			var visual := _tile_visual(layer.cells, -house_root)
			visual.name = str(layer.name)
			house.add_child(visual)
		elif layer.id == int(spec.fence_layer_id):
			# Individual bases can Y-sort along the side rails; leave the source gate open.
			for cell: Dictionary in layer.cells:
				var segment := StaticBody2D.new()
				segment.name = "Fence_%d_%d" % [cell.at.x, cell.at.y]
				segment.collision_layer = 2
				segment.position = offset + Vector2(cell.at) * 16 + Vector2(8, 16)
				get_node("Actors").add_child(segment)
				segment.add_child(_tile_visual([cell], -Vector2(cell.at) * 16 - Vector2(8, 16)))
				var profile_id := str(int(cell.gid) & 0x0fffffff)
				assert(spec.fence_collision_profiles.has(profile_id), "Unmapped fence piece GID: " + profile_id)
				var profile: Dictionary = spec.fence_collision_profiles[profile_id]
				for part: Dictionary in profile.shapes:
					_add_rectangle(segment, Vector2(part.size[0], part.size[1]), Vector2(part.offset[0], part.offset[1]))

func _tile_visual(cells: Array, offset: Vector2) -> Node2D:
	var visual := HOME_TILES.new()
	visual.cells = cells
	visual.tilesets = home_mapping.tilesets
	visual.source_offset = offset
	return visual

func _add_rectangle(body: StaticBody2D, size: Vector2, offset: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	collider.position = offset
	body.add_child(collider)
