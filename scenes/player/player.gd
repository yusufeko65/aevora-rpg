class_name PlayerV2
extends CharacterBody2D

## Provisional ART-001 review values, decoupled from source animation timing.
@export var walk_speed := 48.0
@export var run_speed := 112.0
@onready var visual: SourceSprite = $VisualRoot/SourceSprite
var input_enabled := true
var attacking := false
var attack_velocity := Vector2.ZERO

func _ready() -> void:
	visual.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	if not input_enabled:
		velocity = Vector2.ZERO
		return
	if attacking:
		move_attack()
		return
	var axis := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var running := Input.is_action_pressed("run")
	if Input.is_action_just_pressed("attack_primary") and start_attack(axis, running):
		move_attack()
		return
	velocity = axis * (run_speed if running else walk_speed)
	move_and_slide()
	var next_direction := facing_for(axis, visual.direction)
	var next_state := "idle" if axis.is_zero_approx() else ("run" if running else "walk")
	visual.set_pose(next_state, next_direction)

func start_attack(axis := Vector2.ZERO, running := false) -> bool:
	if attacking or not visual.sword:
		return false
	attacking = true
	var family := "attack" if axis.is_zero_approx() else ("run_attack" if running else "walk_attack")
	attack_velocity = axis * (run_speed if running else walk_speed)
	velocity = attack_velocity
	visual.set_pose(family, facing_for(axis, visual.direction))
	return true

func move_attack() -> void:
	# Capture direction/speed class once; collision can stop or slide the root,
	# but never changes the locked source facing or forces travel through geometry.
	velocity = attack_velocity
	if not velocity.is_zero_approx():
		move_and_slide()

func toggle_sword() -> void:
	# Keep all attack layers intact; Tab is ignored until the one-shot completes.
	if not attacking:
		visual.sword = not visual.sword
		visual.queue_redraw()

func _on_animation_finished(completed_state: String) -> void:
	if completed_state not in ["attack", "walk_attack", "run_attack"] or not attacking:
		return
	attacking = false
	attack_velocity = Vector2.ZERO
	velocity = Vector2.ZERO
	var axis := Input.get_vector("move_left", "move_right", "move_up", "move_down") if input_enabled else Vector2.ZERO
	var locomotion := "idle" if axis.is_zero_approx() else ("run" if Input.is_action_pressed("run") else "walk")
	visual.set_pose(locomotion, facing_for(axis, visual.direction))

## Horizontal wins exact diagonal ties; no mirroring or last-key race.
static func facing_for(axis: Vector2, previous: String) -> String:
	if axis.is_zero_approx():
		return previous
	if absf(axis.x) >= absf(axis.y):
		return "right" if axis.x > 0 else "left"
	return "down" if axis.y > 0 else "up"
