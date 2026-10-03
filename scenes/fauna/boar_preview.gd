extends Node2D

@onready var visual: SourceSprite = $SourceSprite
var preview_mode := "idle"
var seconds := 0.0

func _process(delta: float) -> void:
	seconds += delta
	# Stationary animation preview only: no AI, navigation, attack or world movement.
	visual.set_pose(preview_mode, ["down", "up", "left", "right"][int(seconds / 3.6) % 4])
