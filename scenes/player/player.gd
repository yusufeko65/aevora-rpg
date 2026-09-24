class_name PlayerController
extends CharacterBody2D

signal focused_target_changed(target: InteractionTarget)
signal interaction_completed(message: String)

@export var move_speed := 112.0

@onready var interaction_probe: Area2D = $InteractionProbe
@onready var visual: Sprite2D = $Visual

var facing := Vector2.DOWN
var focused_target: InteractionTarget
var _walk_time := 0.0

const FRAME_START := Vector2(276.0, 10.0)
const FRAME_WIDTH := 224.0
const FRAME_HEIGHT := 260.0
const WALK_FPS := 8.0


func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.length_squared() > 0.0:
		facing = input_vector.normalized()
		_walk_time += delta
	else:
		_walk_time = 0.0
	velocity = input_vector.normalized() * move_speed
	move_and_slide()
	_update_visual(input_vector)
	_update_focused_target()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_interact()


func get_interaction_prompt() -> String:
	if is_instance_valid(focused_target):
		return focused_target.get_interaction_prompt()
	return ""


func _update_focused_target() -> void:
	var nearest: InteractionTarget
	var nearest_distance := INF
	for area in interaction_probe.get_overlapping_areas():
		if area is not InteractionTarget:
			continue
		var candidate := area as InteractionTarget
		if not candidate.can_interact(self):
			continue
		var distance := global_position.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	if nearest == focused_target:
		return
	if is_instance_valid(focused_target):
		focused_target.set_focused(false)
	focused_target = nearest
	if is_instance_valid(focused_target):
		focused_target.set_focused(true)
	focused_target_changed.emit(focused_target)


func _interact() -> void:
	if not is_instance_valid(focused_target):
		interaction_completed.emit("Nothing nearby responds.")
		return
	var response := focused_target.interact(self)
	if not response.is_empty():
		interaction_completed.emit(response)


func _update_visual(input_vector: Vector2) -> void:
	var row := 0
	if absf(facing.x) > absf(facing.y):
		row = 1 if facing.x < 0.0 else 2
	elif facing.y < 0.0:
		row = 3
	var frame := 0
	if input_vector.length_squared() > 0.0:
		frame = int(_walk_time * WALK_FPS) % 4
	visual.region_rect = Rect2(FRAME_START + Vector2(frame * FRAME_WIDTH, row * FRAME_HEIGHT), Vector2(FRAME_WIDTH, FRAME_HEIGHT))
