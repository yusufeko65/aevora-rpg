class_name InteractionTarget
extends Area2D

signal interaction_requested(actor: Node)

@export var prompt_text := "Interact"
@export_multiline var response_text := "There is nothing more to learn here yet."
@export var enabled := true
@export var focus_radius := 18.0

var _focused := false


func _ready() -> void:
	add_to_group("interactable")
	queue_redraw()


func can_interact(_actor: Node) -> bool:
	return enabled


func get_interaction_prompt() -> String:
	return prompt_text


func set_focused(value: bool) -> void:
	if _focused == value:
		return
	_focused = value
	queue_redraw()


func interact(actor: Node) -> String:
	if not can_interact(actor):
		return ""
	interaction_requested.emit(actor)
	return response_text


func _draw() -> void:
	if not _focused:
		return
	draw_arc(Vector2.ZERO, focus_radius, 0.0, TAU, 32, Color("#f4d35e"), 2.0)
	draw_circle(Vector2(0, -focus_radius - 7), 3.0, Color("#f4d35e"))
