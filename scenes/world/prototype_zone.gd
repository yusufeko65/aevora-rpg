class_name PrototypeZone
extends Node2D

@export var zone_id := "prototype.first_village_edge"
@export var display_name := "First Village — River Road"


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	# Ground and layered landmarks follow the provisional 32 px logical grid.
	draw_rect(Rect2(0, 0, 1152, 648), Color("#6f8b4b"))
	for y in range(64, 576, 32):
		for x in range(32, 1120, 64):
			draw_circle(Vector2(x + (y % 64), y), 1.2, Color("#91a963"))

	# Field, road, house, river, and bank.
	draw_rect(Rect2(332, 116, 288, 160), Color("#8e7042"))
	for x in range(348, 612, 24):
		draw_line(Vector2(x, 124), Vector2(x, 268), Color("#b09156"), 2.0)
	draw_rect(Rect2(0, 306, 920, 92), Color("#a68b61"))
	draw_rect(Rect2(80, 78, 224, 166), Color("#4a3524"))
	draw_polygon(PackedVector2Array([Vector2(64, 92), Vector2(192, 28), Vector2(320, 92)]), PackedColorArray([Color("#704332")]))
	draw_rect(Rect2(920, 0, 232, 648), Color("#3d7891"))
	for y in range(24, 648, 48):
		draw_line(Vector2(936, y), Vector2(1128, y + 14), Color("#61a0af"), 2.0)
	draw_rect(Rect2(896, 0, 24, 648), Color("#9d8d65"))

	# Compact forest edge.
	for tree_position in [Vector2(54, 470), Vector2(116, 520), Vector2(208, 478), Vector2(776, 118), Vector2(842, 160)]:
		draw_circle(tree_position, 24, Color("#345c3b"))
		draw_circle(tree_position + Vector2(-10, -8), 14, Color("#426f43"))

	# Small landmark captions are intentionally debug-like placeholder art.
	draw_string(ThemeDB.fallback_font, Vector2(104, 222), "PLAYER HOUSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#ead8ab"))
	draw_string(ThemeDB.fallback_font, Vector2(408, 146), "TEST FIELD", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#e2cc91"))
	draw_string(ThemeDB.fallback_font, Vector2(962, 44), "RIVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#d8f0ea"))
