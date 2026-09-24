class_name PrototypeZone
extends Node2D

@export var zone_id := "prototype.first_village_edge"
@export var display_name := "First Village — Home Crossing"


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	for tile_y in range(0, 720, 32):
		for tile_x in range(0, 1152, 32):
			var alternate := int(tile_x / 32) + int(tile_y / 32)
			var grass := Color("#668348") if alternate % 3 else Color("#6d8950")
			draw_rect(Rect2(tile_x, tile_y, 32, 32), grass)
			if alternate % 2 == 0:
				draw_rect(Rect2(tile_x + 8, tile_y + 11, 2, 3), Color("#8ca55f"))
				draw_rect(Rect2(tile_x + 22, tile_y + 23, 2, 2), Color("#506f3d"))

	var road := PackedVector2Array([Vector2(0, 326), Vector2(120, 316), Vector2(250, 329), Vector2(390, 320), Vector2(520, 334), Vector2(660, 323), Vector2(810, 331), Vector2(970, 318), Vector2(1152, 330), Vector2(1152, 420), Vector2(1010, 412), Vector2(850, 424), Vector2(700, 411), Vector2(550, 421), Vector2(400, 409), Vector2(230, 420), Vector2(80, 410), Vector2(0, 418)])
	draw_colored_polygon(road, Color("#a88255"))
	draw_polyline(PackedVector2Array([Vector2(0, 346), Vector2(180, 340), Vector2(360, 350), Vector2(560, 343), Vector2(770, 352), Vector2(960, 340), Vector2(1152, 348)]), Color("#b79566"), 5.0)
	for patch in [Rect2(92, 372, 38, 9), Rect2(285, 347, 26, 7), Rect2(498, 386, 44, 8), Rect2(742, 358, 34, 7), Rect2(986, 382, 48, 9)]:
		draw_rect(patch, Color("#8d6d49"))

	draw_rect(Rect2(0, 476, 1152, 146), Color("#39788b"))
	draw_rect(Rect2(0, 482, 1152, 10), Color("#8e855f"))
	draw_rect(Rect2(0, 610, 1152, 12), Color("#8b805b"))
	for y in range(505, 600, 28):
		for x in range((y * 3) % 80, 1152, 96):
			draw_line(Vector2(x, y), Vector2(x + 42, y + 4), Color("#5aa0aa"), 2.0)

	draw_colored_polygon(PackedVector2Array([Vector2(252, 260), Vector2(320, 260), Vector2(334, 335), Vector2(320, 470), Vector2(264, 470), Vector2(278, 338)]), Color("#a98b60"))
