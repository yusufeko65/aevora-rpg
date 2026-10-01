class_name CharacterValidationOverlay
extends Node2D

@export var manifest_path := "res://data/character_visual/prototype_validation_001.json"
@export var show_guides := true
@export var show_bounds := true

var _canvas := Vector2i(64, 64)
var _anchor := Vector2i(32, 48)


func _ready() -> void:
	var result := CharacterVisualManifest.load_and_validate(manifest_path, false)
	if result.ok:
		_canvas = Vector2i(int(result.data.canvas.width), int(result.data.canvas.height))
		_anchor = Vector2i(int(result.data.anchor.x), int(result.data.anchor.y))
	queue_redraw()


func set_guides_visible(value: bool) -> void:
	show_guides = value
	queue_redraw()


func set_bounds_visible(value: bool) -> void:
	show_bounds = value
	queue_redraw()


func _draw() -> void:
	if not show_guides and not show_bounds:
		return
	var top_left := Vector2(-_anchor.x, -_anchor.y)
	if show_bounds:
		draw_rect(Rect2(top_left, Vector2(_canvas)), Color(0.31, 0.94, 0.95, 0.9), false, 0.5)
	if show_guides:
		draw_line(Vector2(0, -_anchor.y), Vector2(0, _canvas.y - _anchor.y), Color(0.98, 0.80, 0.25, 0.85), 0.5)
		draw_line(Vector2(-_anchor.x, 0), Vector2(_canvas.x - _anchor.x, 0), Color(0.98, 0.45, 0.35, 0.85), 0.5)
		draw_line(Vector2(-3, 0), Vector2(3, 0), Color.WHITE, 0.75)
		draw_line(Vector2(0, -3), Vector2(0, 3), Color.WHITE, 0.75)
		draw_circle(Vector2(0, -18), 1.5, Color(0.58, 0.92, 0.48, 0.9), false, 0.5)
