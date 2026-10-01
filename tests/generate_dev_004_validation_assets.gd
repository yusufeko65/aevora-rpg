extends SceneTree

const OUT_CHARACTER := "res://art/prototype/dev_004/characters"
const OUT_EQUIPMENT := "res://art/prototype/dev_004/equipment"
const OUT_INVALID := "res://art/prototype/dev_004/invalid_fixtures"
const CANVAS := Vector2i(64, 64)
const DIRECTION_ROWS := {"up": 0, "right": 1, "down": 2, "left": 3}
const STATES := {
	"idle": 4,
	"walk": 6,
	"run": 8,
	"attack": 5,
	"hurt": 3,
	"dead": 6,
	"tool": 7,
}

const SKIN := Color8(222, 166, 120, 255)
const SKIN_SHADOW := Color8(174, 112, 83, 255)
const HAIR := Color8(174, 76, 45, 255)
const HAIR_LIGHT := Color8(219, 111, 55, 255)
const CLOTH := Color8(68, 123, 79, 255)
const CLOTH_LIGHT := Color8(101, 158, 92, 255)
const BOOT := Color8(91, 58, 42, 255)
const EQUIPMENT := Color8(205, 166, 60, 255)
const EQUIPMENT_DARK := Color8(112, 79, 42, 255)


func _initialize() -> void:
	call_deferred("_generate")


func _generate() -> void:
	for directory in [OUT_CHARACTER, OUT_EQUIPMENT, OUT_INVALID]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	for state in STATES:
		for layer in ["body", "hair", "outfit", "equipment_test"]:
			var image := _make_atlas(state, STATES[state], layer)
			var folder := OUT_EQUIPMENT if layer == "equipment_test" else OUT_CHARACTER
			var path := "%s/prototype_validation_001_%s_%s.png" % [folder, layer, state]
			var error := image.save_png(ProjectSettings.globalize_path(path))
			if error != OK:
				push_error("Could not save %s: %s" % [path, error_string(error)])
				quit(1)
				return
	_make_invalid_fixtures()
	print("Generated DEV-004 fixed-canvas validation assets")
	quit(0)


func _make_atlas(state: String, frame_count: int, layer: String) -> Image:
	var image := Image.create_empty(frame_count * CANVAS.x, DIRECTION_ROWS.size() * CANVAS.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for direction in DIRECTION_ROWS:
		for frame in frame_count:
			_draw_frame(image, Vector2i(frame * CANVAS.x, DIRECTION_ROWS[direction] * CANVAS.y), state, direction, frame, frame_count, layer)
	return image


func _draw_frame(image: Image, origin: Vector2i, state: String, direction: String, frame: int, frame_count: int, layer: String) -> void:
	var phase := float(frame) / float(maxi(frame_count, 1))
	var stride := 0
	if state == "walk":
		stride = [3, 1, 0, -3, -1, 0][frame]
	elif state == "run":
		stride = [4, 2, 0, -2, -4, -2, 0, 2][frame]
	var bob := 0
	if state == "walk":
		bob = [0, 1, -1, 0, 1, -1][frame]
	elif state == "run":
		bob = [0, 1, -1, 0, 0, 1, -1, 0][frame]
	elif state == "idle":
		bob = 1 if frame == 2 else 0
	var center_x := 32
	if direction == "left" or direction == "right":
		center_x += 0
	if state == "hurt":
		center_x += frame - 1
	if state == "dead":
		_draw_dead(image, origin, frame, layer)
		return
	match layer:
		"body":
			_draw_body(image, origin, center_x, bob, state, direction, frame, phase)
		"hair":
			_draw_hair(image, origin, center_x, bob, direction)
		"outfit":
			_draw_outfit(image, origin, center_x, bob, state, direction, stride, frame)
		"equipment_test":
			_draw_equipment(image, origin, center_x, state, direction, frame, phase)


func _draw_body(image: Image, origin: Vector2i, cx: int, bob: int, state: String, direction: String, frame: int, phase: float) -> void:
	_fill_rect(image, origin + Vector2i(cx - 4, 18 + bob), Vector2i(9, 9), SKIN_SHADOW)
	_fill_rect(image, origin + Vector2i(cx - 3, 18 + bob), Vector2i(6, 7), SKIN)
	if direction == "down":
		_set_pixel(image, origin + Vector2i(cx - 2, 21 + bob), Color8(58, 44, 42, 255))
		_set_pixel(image, origin + Vector2i(cx + 2, 21 + bob), Color8(58, 44, 42, 255))
	var arm_raise := 0
	if state == "attack":
		arm_raise = int(round(sin(phase * PI) * 7.0))
	elif state == "tool":
		arm_raise = int(round(sin(phase * PI) * 10.0))
	var hand_y := 33 + bob - arm_raise
	_fill_rect(image, origin + Vector2i(cx - 8, hand_y), Vector2i(3, 4), SKIN)
	_fill_rect(image, origin + Vector2i(cx + 6, hand_y), Vector2i(3, 4), SKIN)
	if state == "hurt" and frame == 1:
		_fill_rect(image, origin + Vector2i(cx - 6, 26 + bob), Vector2i(12, 2), Color8(229, 94, 78, 255))


func _draw_hair(image: Image, origin: Vector2i, cx: int, bob: int, direction: String) -> void:
	_fill_rect(image, origin + Vector2i(cx - 5, 15 + bob), Vector2i(11, 5), HAIR)
	_fill_rect(image, origin + Vector2i(cx - 5, 19 + bob), Vector2i(3, 5), HAIR)
	if direction == "up":
		_fill_rect(image, origin + Vector2i(cx - 4, 20 + bob), Vector2i(9, 6), HAIR)
	elif direction == "left":
		_fill_rect(image, origin + Vector2i(cx - 6, 18 + bob), Vector2i(3, 6), HAIR)
	elif direction == "right":
		_fill_rect(image, origin + Vector2i(cx + 4, 18 + bob), Vector2i(3, 6), HAIR)
	_fill_rect(image, origin + Vector2i(cx - 2, 16 + bob), Vector2i(5, 2), HAIR_LIGHT)


func _draw_outfit(image: Image, origin: Vector2i, cx: int, bob: int, state: String, _direction: String, stride: int, frame: int) -> void:
	_fill_rect(image, origin + Vector2i(cx - 5, 27 + bob), Vector2i(11, 11), CLOTH)
	_fill_rect(image, origin + Vector2i(cx - 3, 28 + bob), Vector2i(7, 3), CLOTH_LIGHT)
	var left_x := cx - 4
	var right_x := cx + 1
	if stride > 0:
		left_x -= mini(stride, 3)
		right_x += 1
	elif stride < 0:
		right_x += mini(-stride, 3)
		left_x -= 1
	var leg_height := 9
	if state == "hurt":
		leg_height = 8 - frame
	_fill_rect(image, origin + Vector2i(left_x, 38 + bob), Vector2i(4, leg_height), CLOTH)
	_fill_rect(image, origin + Vector2i(right_x, 38 + bob), Vector2i(4, leg_height), CLOTH)
	_fill_rect(image, origin + Vector2i(left_x - 1, 46), Vector2i(5, 2), BOOT)
	_fill_rect(image, origin + Vector2i(right_x, 46), Vector2i(5, 2), BOOT)


func _draw_equipment(image: Image, origin: Vector2i, cx: int, state: String, direction: String, frame: int, phase: float) -> void:
	var side := -1 if direction == "left" else 1
	var x := cx + side * 8
	var y := 30
	if direction == "up":
		x = cx - 8
	if state == "attack":
		y -= int(round(sin(phase * PI) * 8.0))
	if state == "tool":
		y -= int(round(sin(phase * PI) * 11.0))
	_fill_rect(image, origin + Vector2i(x - 3, y - 4), Vector2i(7, 10), EQUIPMENT_DARK)
	_fill_rect(image, origin + Vector2i(x - 2, y - 3), Vector2i(5, 8), EQUIPMENT)
	if frame % 2 == 1:
		_set_pixel(image, origin + Vector2i(x, y - 2), Color8(238, 210, 99, 255))


func _draw_dead(image: Image, origin: Vector2i, frame: int, layer: String) -> void:
	var width := 12 + frame * 4
	var x := 32 - width / 2
	match layer:
		"body":
			_fill_rect(image, origin + Vector2i(x, 39), Vector2i(width, 7), SKIN)
		"hair":
			_fill_rect(image, origin + Vector2i(x - 2, 37), Vector2i(8, 6), HAIR)
		"outfit":
			_fill_rect(image, origin + Vector2i(x + 5, 40), Vector2i(maxi(width - 5, 4), 7), CLOTH)
		"equipment_test":
			_fill_rect(image, origin + Vector2i(43, 45), Vector2i(9, 3), EQUIPMENT_DARK)


func _make_invalid_fixtures() -> void:
	var opaque := Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)
	opaque.fill(Color8(86, 68, 51, 255))
	opaque.save_png(ProjectSettings.globalize_path(OUT_INVALID + "/opaque_background.png"))
	var wrong_size := Image.create_empty(63, 64, false, Image.FORMAT_RGBA8)
	wrong_size.fill(Color.TRANSPARENT)
	_set_pixel(wrong_size, Vector2i(31, 47), Color.WHITE)
	wrong_size.save_png(ProjectSettings.globalize_path(OUT_INVALID + "/wrong_dimensions.png"))


func _fill_rect(image: Image, position: Vector2i, size: Vector2i, color: Color) -> void:
	for y in range(position.y, position.y + size.y):
		for x in range(position.x, position.x + size.x):
			if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
				image.set_pixel(x, y, color)


func _set_pixel(image: Image, position: Vector2i, color: Color) -> void:
	if position.x >= 0 and position.y >= 0 and position.x < image.get_width() and position.y < image.get_height():
		image.set_pixelv(position, color)
