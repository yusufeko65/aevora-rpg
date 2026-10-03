extends Node2D

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var world := get_parent()
	var player := world.get_node("Actors/Player") as PlayerV2
	if not player.visual.guides:
		return
	# Draw above terrain using the actual physics shapes, not canopy/frame bounds.
	for body: Node2D in [player, world.get_node("Actors/Tree64"), world.get_node("Actors/Tree128")]:
		var collider: CollisionShape2D = body.get_node("CollisionShape2D" if body == player else "Trunk")
		var size: Vector2 = (collider.shape as RectangleShape2D).size
		var footprint := Rect2(body.position + collider.position - size / 2, size)
		draw_rect(footprint, Color(1, 0.3, 0.8, 0.4))
		draw_rect(footprint, Color(1, 0.3, 0.8), false)
		draw_circle(body.position, 1, Color.WHITE)
