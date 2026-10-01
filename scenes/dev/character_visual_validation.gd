class_name CharacterVisualValidation
extends Node2D

const STATES := ["idle", "walk", "run", "attack", "hurt", "dead", "tool"]
const DIRECTIONS := ["down", "up", "left", "right"]

@onready var main_visual: CharacterVisual = $CharacterRoot/CharacterVisual
@onready var preview_64: CharacterVisual = $Preview64/CharacterVisual
@onready var preview_32: CharacterVisual = $Preview32/CharacterVisual
@onready var overlay: CharacterValidationOverlay = $CharacterRoot/ValidationOverlay
@onready var debug_label: Label = $UI/DebugPanel/Margin/DebugLabel
@onready var light_background: ColorRect = $LightBackground
@onready var dark_background: ColorRect = $DarkBackground

var _equipment_enabled := true
var _slow_motion := false
var _background_mode := 0


func _ready() -> void:
	_update_debug_text()


func _process(_delta: float) -> void:
	_update_debug_text()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key_event := event as InputEventKey
	match key_event.physical_keycode:
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7:
			_set_state(STATES[int(key_event.physical_keycode - KEY_1)])
		KEY_W, KEY_UP:
			_set_direction("up")
		KEY_S, KEY_DOWN:
			_set_direction("down")
		KEY_A, KEY_LEFT:
			_set_direction("left")
		KEY_D, KEY_RIGHT:
			_set_direction("right")
		KEY_Q:
			_set_equipment(false)
		KEY_E:
			_set_equipment(true)
		KEY_F1:
			overlay.set_guides_visible(not overlay.show_guides)
		KEY_F2:
			overlay.set_bounds_visible(not overlay.show_bounds)
		KEY_F3:
			_cycle_background()
		KEY_F4:
			_slow_motion = not _slow_motion
			var rate := 0.25 if _slow_motion else 1.0
			for visual in _visuals():
				visual.set_playback_rate(rate)


func _set_state(state: String) -> void:
	for visual in _visuals():
		visual.set_state(state)


func _set_direction(direction: String) -> void:
	for visual in _visuals():
		visual.set_direction(direction)


func _set_equipment(value: bool) -> void:
	_equipment_enabled = value
	for visual in _visuals():
		visual.set_equipment_visible(value)


func _cycle_background() -> void:
	_background_mode = (_background_mode + 1) % 3
	match _background_mode:
		0:
			light_background.color = Color("#c7c28b")
			dark_background.color = Color("#263a36")
		1:
			light_background.color = Color("#8ca664")
			dark_background.color = Color("#3d5f69")
		2:
			light_background.color = Color("#d5b27b")
			dark_background.color = Color("#392f45")


func _update_debug_text() -> void:
	var info := main_visual.get_debug_snapshot()
	if info.is_empty():
		debug_label.text = "Loading validation manifest..."
		return
	debug_label.text = "VIS-001 / DEV-004 — PROTOTYPE VALIDATION\nvisual_id: %s\nstate: %s    direction: %s\nframe: %d / %d    duration: %d ms    loop: %s\nanchor: (%d, %d)    authoring: 64×64\nmain inspection: 4×    previews: 64 px / 32 px canvas\nlayers: %s\nequipment: %s    playback: %s\n\n1–7 states  •  WASD/arrows direction  •  Q/E equipment\nF1 anchor guides  •  F2 canvas bounds  •  F3 terrain  •  F4 slow motion" % [
		info.visual_id,
		info.state,
		info.direction,
		int(info.frame_index) + 1,
		info.frame_count,
		info.duration_ms,
		"yes" if info.loop else "no",
		info.anchor.x,
		info.anchor.y,
		", ".join(info.layers),
		"visible" if _equipment_enabled else "hidden (gameplay unchanged)",
		"0.25×" if _slow_motion else "1×",
	]


func _visuals() -> Array[CharacterVisual]:
	return [main_visual, preview_64, preview_32]
