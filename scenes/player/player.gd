class_name PlayerV2
extends CharacterBody2D

## Provisional ART-001 review values, decoupled from source animation timing.
@export var walk_speed := 48.0
@export var run_speed := 112.0
@onready var visual: SourceSprite = $VisualRoot/SourceSprite
var input_enabled := true

func _physics_process(_delta: float) -> void:
	if not input_enabled:
		velocity = Vector2.ZERO
		return
	var axis := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var running := Input.is_action_pressed("run")
	velocity = axis * (run_speed if running else walk_speed)
	move_and_slide()
	var next_direction := facing_for(axis, visual.direction)
	var next_state := "idle" if axis.is_zero_approx() else ("run" if running else "walk")
	visual.set_pose(next_state, next_direction)

## Horizontal wins exact diagonal ties; no mirroring or last-key race.
static func facing_for(axis: Vector2, previous: String) -> String:
	if axis.is_zero_approx():
		return previous
	if absf(axis.x) >= absf(axis.y):
		return "right" if axis.x > 0 else "left"
	return "down" if axis.y > 0 else "up"
