extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := load("res://scenes/main/main.tscn") as PackedScene
	var main := scene.instantiate()
	root.add_child(main)
	await physics_frame
	var player := main.get_node("PrototypeZone/Player") as PlayerController

	_assert(_travel(player, Vector2(326, 450), Vector2(0, 200)) > 190.0, "Bridge crosses north to south")
	_assert(_travel(player, Vector2(326, 650), Vector2(0, -220)) > 210.0, "Bridge crosses south to north")
	_assert(_travel(player, Vector2(450, 450), Vector2(0, 200)) < 40.0, "River blocks entry beside bridge")
	_assert(_travel(player, Vector2(326, 550), Vector2(100, 0)) < 35.0, "Bridge side rail prevents lateral river entry")
	_assert(_travel(player, Vector2(70, 205), Vector2(0, 110)) < 70.0, "Tree trunk blocks north to south")
	_assert(_travel(player, Vector2(20, 260), Vector2(100, 0)) < 60.0, "Tree trunk blocks west to east")
	_assert(_travel(player, Vector2(32, 222), Vector2(76, 76)) < 70.0, "Tree trunk rejects diagonal corner clipping")
	_assert(_travel(player, Vector2(710, 140), Vector2(0, 60)) < 25.0, "Crop row blocks direct traversal")
	_assert(_travel(player, Vector2(850, 100), Vector2(0, 200)) > 190.0, "Garden outer margin remains walkable")
	_assert(_travel(player, Vector2(700, 100), Vector2(0, 60)) < 30.0, "Fence rail blocks movement")
	_assert(_travel(player, Vector2(850, 100), Vector2(0, 200)) > 190.0, "Fence opening remains traversable")
	_assert(_travel(player, Vector2(285, 310), Vector2(0, -100)) < 30.0, "House walls block movement while entrance remains approachable")

	print("DEV-003 collision traversal test passed")
	quit(0)


func _travel(player: CharacterBody2D, origin: Vector2, motion: Vector2) -> float:
	player.global_position = origin
	var before := player.global_position
	player.move_and_collide(motion)
	return player.global_position.distance_to(before)


func _assert(condition: bool, description: String) -> void:
	if condition:
		return
	push_error("Collision test failed: %s" % description)
	quit(1)
