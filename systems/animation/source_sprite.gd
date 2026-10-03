class_name SourceSprite
extends Node2D

const SOURCE := preload("res://data/source_mapping/craftpix.json")

@export_enum("human", "boar") var source_kind := "human"
var mapping: Dictionary
var state := "idle"
var direction := "down"
var frame_index := 0
var elapsed_ms := 0.0
var sword := false
var separate_shadow := false
var guides := false
var textures: Dictionary = {}

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mapping = SOURCE.data[source_kind]
	queue_redraw()

func _process(delta: float) -> void:
	advance(delta)

func set_pose(next_state: String, next_direction: String) -> void:
	assert(mapping.states.has(next_state) and mapping.direction_rows.has(next_direction))
	if state != next_state or direction != next_direction:
		state = next_state
		direction = next_direction
		frame_index = 0
		elapsed_ms = 0.0
	queue_redraw()

func advance(delta: float) -> void:
	elapsed_ms += delta * 1000.0
	while elapsed_ms + 0.00001 >= duration_ms():
		elapsed_ms -= duration_ms()
		frame_index = (frame_index + 1) % int(mapping.states[state].frame_count)
	queue_redraw()

func duration_ms() -> float:
	return float(mapping.states[state].durations_ms[frame_index])

func source_row() -> int:
	return int(mapping.direction_rows[direction])

func source_region(layer: Dictionary) -> Rect2:
	var column: int = layer.source_columns[str(source_row())].columns[frame_index]
	var cell: int = mapping.frame_size
	return Rect2(column * cell, source_row() * cell, cell, cell)

func current_layers() -> Array:
	var pose: Dictionary = mapping.states[state]
	if source_kind == "boar":
		return [pose.full]
	if sword:
		return [pose.shadow] + pose.sword_layers
	if separate_shadow:
		return [pose.shadow, pose.unarmed_body]
	return [pose.unarmed_full]

func _draw() -> void:
	if mapping.is_empty():
		return
	var pivot := Vector2(mapping.pivot[0], mapping.pivot[1])
	var cell := Vector2.ONE * int(mapping.frame_size)
	for layer: Dictionary in current_layers():
		var path: String = layer.file
		if not textures.has(path):
			textures[path] = load(path) as Texture2D
		draw_texture_rect_region(textures[path], Rect2(-pivot, cell), source_region(layer))
	if guides:
		draw_rect(Rect2(-pivot, cell), Color(0.95, 0.8, 0.25), false)
		draw_line(Vector2(-pivot.x, 0), Vector2(cell.x - pivot.x, 0), Color(0.3, 0.95, 0.9))
		draw_line(Vector2(0, -pivot.y), Vector2(0, cell.y - pivot.y), Color(0.3, 0.95, 0.9, 0.5))
		draw_circle(Vector2.ZERO, 2, Color(1, 0.4, 0.4))
