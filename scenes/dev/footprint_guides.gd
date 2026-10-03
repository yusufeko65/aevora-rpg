extends Node2D

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var world := get_parent()
	var player := world.get_node("Actors/Player") as PlayerV2
	if not player.visual.guides:
		return
	# Draw above terrain using the actual physics shapes, not canopy/frame bounds.
	for collider: CollisionShape2D in world.get_node("Actors").find_children("*", "CollisionShape2D", true, false):
		if not collider.shape is RectangleShape2D:
			continue
		var size: Vector2 = (collider.shape as RectangleShape2D).size
		var footprint := Rect2(to_local(collider.global_position) - size / 2, size)
		draw_rect(footprint, Color(1, 0.3, 0.8, 0.4))
		draw_rect(footprint, Color(1, 0.3, 0.8), false)
		draw_circle(to_local(collider.get_parent().global_position), 1, Color.WHITE)
