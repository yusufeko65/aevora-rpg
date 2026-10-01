extends SceneTree

const MANIFEST_PATH := "res://data/character_visual/prototype_validation_001.json"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var valid := CharacterVisualManifest.load_and_validate(MANIFEST_PATH, true)
	_assert(valid.ok, "valid prototype manifest passes: %s" % "; ".join(valid.errors))
	var data: Dictionary = valid.data
	_assert(data.status == "prototype_validation", "test asset cannot be mistaken for canonical art")
	_assert(Vector2i(data.canvas.width, data.canvas.height) == Vector2i(64, 64), "authoring canvas is 64x64")
	_assert(Vector2i(data.anchor.x, data.anchor.y) == Vector2i(32, 48), "provisional anchor is explicit")
	_assert(data.animations.idle.frame_count == 4, "idle frame count is data-driven")
	_assert(data.animations.run.frame_count == 8, "run frame count is data-driven")
	_assert(data.animations.attack.frame_count == 5, "attack proves there is no universal six-frame assumption")
	_assert(data.animations.tool.frame_count == 7, "tool proves action-specific frame count")
	_assert(data.animations.attack.durations_ms[0] != data.animations.attack.durations_ms[1], "attack timing is phase-variable")
	_assert(data.animations.walk.direction_rows.down == 2 and data.animations.walk.direction_rows.up == 0, "direction rows come from metadata, not layout assumptions")

	var bad_frame_count: Dictionary = data.duplicate(true)
	bad_frame_count.animations.walk.frame_count = 0
	_assert(_contains(CharacterVisualManifest.validate_data(bad_frame_count, false), "frame_count"), "invalid frame count fails validation")

	var bad_durations: Dictionary = data.duplicate(true)
	bad_durations.animations.run.durations_ms = [80, 80]
	_assert(_contains(CharacterVisualManifest.validate_data(bad_durations, false), "durations_ms"), "duration-count mismatch fails validation")

	var missing_direction: Dictionary = data.duplicate(true)
	missing_direction.directions.erase("left")
	missing_direction.animations.idle.direction_rows.erase("left")
	_assert(_contains(CharacterVisualManifest.validate_data(missing_direction, false), "missing required direction"), "missing Core direction fails validation")

	var wrong_dimensions := CharacterVisualManifest.validate_png_fixture("res://art/prototype/dev_004/invalid_fixtures/wrong_dimensions.png", Vector2i(64, 64))
	_assert(_contains(wrong_dimensions, "invalid atlas dimensions"), "invalid atlas dimensions are detected")
	var opaque_background := CharacterVisualManifest.validate_png_fixture("res://art/prototype/dev_004/invalid_fixtures/opaque_background.png", Vector2i(64, 64))
	_assert(_contains(opaque_background, "opaque accidental background"), "opaque accidental background is detected")

	print("DEV-004 manifest and PNG validation test passed")
	quit(0)


func _contains(errors: PackedStringArray, fragment: String) -> bool:
	for error in errors:
		if fragment in error:
			return true
	return false


func _assert(condition: bool, description: String) -> void:
	if condition:
		return
	push_error("DEV-004 manifest test failed: %s" % description)
	quit(1)
