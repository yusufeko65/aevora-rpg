extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://scenes/dev/character_visual_validation.tscn") as PackedScene
	_assert(packed != null, "validation scene loads")
	var scene := packed.instantiate()
	root.add_child(scene)
	await process_frame
	var root_node := scene.get_node("CharacterRoot") as Node2D
	var visual := scene.get_node("CharacterRoot/CharacterVisual") as CharacterVisual
	_assert(visual != null and not visual.manifest.is_empty(), "manifest-driven CharacterVisual initializes")
	_assert(visual.get_class() == "Node2D", "visual playback remains independent from movement physics")
	_assert(visual.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "character root uses nearest-neighbor filtering")
	var root_position := root_node.global_position
	for state in CharacterVisualManifest.REQUIRED_STATES:
		_assert(visual.set_state(state), "state is available: %s" % state)
		_assert(root_node.global_position == root_position, "state change preserves CharacterRoot position")
		for direction in CharacterVisualManifest.REQUIRED_DIRECTIONS:
			_assert(visual.set_direction(direction), "%s supports %s" % [state, direction])
			_assert(root_node.global_position == root_position, "direction change preserves CharacterRoot position")

	visual.set_state("walk")
	visual.set_direction("down")
	var expected_region := Rect2(0, 128, 64, 64)
	var body: Sprite2D = visual.get_node("BodyLayers/Body")
	var hair: Sprite2D = visual.get_node("BodyLayers/Hair")
	var outfit: Sprite2D = visual.get_node("BodyLayers/Outfit")
	var equipment_back: Sprite2D = visual.get_node("BackLayers/EquipmentBack")
	var equipment_front: Sprite2D = visual.get_node("FrontLayers/EquipmentFront")
	_assert(body.region_rect == expected_region, "nonstandard down row is resolved from manifest")
	_assert(body.region_rect == hair.region_rect and body.region_rect == outfit.region_rect and body.region_rect == equipment_front.region_rect, "all visible layers share the same frame without lag")
	_assert(equipment_front.visible and not equipment_back.visible, "down-facing equipment renders in front")
	visual.set_direction("up")
	_assert(equipment_back.visible and not equipment_front.visible, "up-facing equipment renders behind body")
	visual.set_equipment_visible(false)
	_assert(not equipment_back.visible and not equipment_front.visible, "visible_on_character behavior can suppress rendering")
	_assert(root_node.global_position == root_position, "equipment visibility does not shift CharacterRoot")
	visual.set_equipment_visible(true)

	visual.set_state("attack")
	visual.set_direction("down")
	visual.set_process(false)
	visual._process(0.165)
	_assert(visual.frame_index == 1, "first attack frame honors its 160 ms duration")
	visual._process(0.085)
	_assert(visual.frame_index == 2, "second attack frame honors its distinct 80 ms duration")

	var preview_64 := scene.get_node("Preview64/CharacterVisual") as CharacterVisual
	var preview_32 := scene.get_node("Preview32/CharacterVisual") as CharacterVisual
	_assert(preview_64.scale == Vector2.ONE and preview_32.scale == Vector2(0.5, 0.5), "scene exposes native and exact 64-to-32 runtime previews")

	print("DEV-004 CharacterVisual scene test passed")
	quit(0)


func _assert(condition: bool, description: String) -> void:
	if condition:
		return
	push_error("DEV-004 CharacterVisual test failed: %s" % description)
	quit(1)
