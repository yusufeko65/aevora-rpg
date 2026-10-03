extends CharacterBody2D

## Ambient presentation only. The unobstructed field avoids navigation/AI scope.
@export var roam_area := Rect2(580, 392, 144, 80)
@export var walk_speed := 24.0
@export var wander_seed := 20261004
@onready var visual: SourceSprite = $SourceSprite
var ambient_state := "idle"
var remaining := 0.0
var target := Vector2.ZERO
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = wander_seed
	_idle()

func _physics_process(delta: float) -> void:
	remaining -= delta
	if ambient_state == "idle":
		velocity = Vector2.ZERO
		if remaining <= 0:
			_begin_walk()
		return
	var to_target := target - position
	if remaining <= 0 or to_target.length() <= 1.0:
		_idle()
		return
	var previous := position
	velocity = to_target.normalized() * minf(walk_speed, to_target.length() / delta)
	move_and_slide()
	position = position.clamp(roam_area.position, roam_area.end)
	velocity = (position - previous) / delta
	if velocity.is_zero_approx():
		_idle()
	else:
		visual.set_pose("walk", PlayerV2.facing_for(velocity, visual.direction))

func _idle() -> void:
	ambient_state = "idle"
	velocity = Vector2.ZERO
	remaining = rng.randf_range(1.5, 4.0)
	visual.set_pose("idle", visual.direction)

func _begin_walk() -> void:
	# Inset keeps the fixed 16x8 feet shape inside the configured rectangle.
	var safe_area := roam_area.grow(-10.0)
	target = Vector2(rng.randf_range(safe_area.position.x, safe_area.end.x), rng.randf_range(safe_area.position.y, safe_area.end.y))
	ambient_state = "walk"
	remaining = rng.randf_range(1.0, 3.0)
