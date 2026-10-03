extends Node2D

const SPRITE := preload("res://systems/animation/source_sprite.gd")

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for row in range(3):
		for column in range(4):
			var sprite := SPRITE.new()
			sprite.position = Vector2(112 + column * 136, 90 + row * 90)
			add_child(sprite)
			sprite.set_pose(["idle", "walk", "run"][row], ["down", "left", "right", "up"][column])
			sprite.frame_index = 1 if row == 1 else (3 if row == 2 else 0)
			sprite.guides = true
			sprite.set_process(false)
			var label := Label.new()
			label.text = "%s %s" % [sprite.state, sprite.direction]
			label.position = sprite.position + Vector2(-42, 24)
			label.add_theme_font_size_override("font_size", 12)
			add_child(label)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("789855"))
	draw_string(ThemeDB.fallback_font, Vector2(12, 20), "DEV-R001 / original 64x64 frames / native 1x / TMX row and timeline mapping", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
