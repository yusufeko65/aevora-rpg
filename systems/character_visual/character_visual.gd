class_name CharacterVisual
extends Node2D

signal frame_changed(state: String, direction: String, frame_index: int)

@export_file("*.json") var manifest_path := "res://data/character_visual/prototype_validation_001.json"
@export var initial_state := "idle"
@export var initial_direction := "down"

@onready var body: Sprite2D = $BodyLayers/Body
@onready var hair: Sprite2D = $BodyLayers/Hair
@onready var outfit: Sprite2D = $BodyLayers/Outfit
@onready var equipment_back: Sprite2D = $BackLayers/EquipmentBack
@onready var equipment_front: Sprite2D = $FrontLayers/EquipmentFront

var manifest: Dictionary
var current_state := "idle"
var current_direction := "down"
var frame_index := 0
var playback_rate := 1.0
var equipment_visible := true
var _elapsed_ms := 0.0
var _textures := {}


func _ready() -> void:
	var result := CharacterVisualManifest.load_and_validate(manifest_path, true)
	if not result.ok:
		push_error("Character visual manifest invalid: %s" % "; ".join(result.errors))
		set_process(false)
		return
	manifest = result.data
	current_state = initial_state
	current_direction = initial_direction
	_apply_state_textures()
	_apply_frame()


func _process(delta: float) -> void:
	if manifest.is_empty() or playback_rate <= 0.0:
		return
	var animation: Dictionary = manifest.animations[current_state]
	var durations: Array = animation.durations_ms
	_elapsed_ms += delta * 1000.0 * playback_rate
	while _elapsed_ms >= float(durations[frame_index]):
		_elapsed_ms -= float(durations[frame_index])
		if frame_index + 1 < int(animation.frame_count):
			frame_index += 1
		elif bool(animation.loop):
			frame_index = 0
		else:
			_elapsed_ms = 0.0
			break
		_apply_frame()


func set_state(value: String) -> bool:
	if manifest.is_empty() or not manifest.animations.has(value):
		return false
	if value == current_state:
		return true
	current_state = value
	frame_index = 0
	_elapsed_ms = 0.0
	_apply_state_textures()
	_apply_frame()
	return true


func set_direction(value: String) -> bool:
	if manifest.is_empty() or value not in manifest.directions:
		return false
	current_direction = value
	_apply_frame()
	return true


func set_equipment_visible(value: bool) -> void:
	equipment_visible = value
	_apply_equipment_occlusion()


func set_playback_rate(value: float) -> void:
	playback_rate = maxf(value, 0.0)


func get_frame_count() -> int:
	return int(manifest.animations[current_state].frame_count) if not manifest.is_empty() else 0


func get_current_duration_ms() -> int:
	return int(manifest.animations[current_state].durations_ms[frame_index]) if not manifest.is_empty() else 0


func get_anchor() -> Vector2i:
	return Vector2i(int(manifest.anchor.x), int(manifest.anchor.y)) if not manifest.is_empty() else Vector2i.ZERO


func get_canvas_size() -> Vector2i:
	return Vector2i(int(manifest.canvas.width), int(manifest.canvas.height)) if not manifest.is_empty() else Vector2i.ZERO


func get_active_layers() -> PackedStringArray:
	var result := PackedStringArray(["body", "hair", "outfit"])
	if equipment_visible:
		result.append("equipment_test_%s" % ("back" if equipment_back.visible else "front"))
	return result


func get_debug_snapshot() -> Dictionary:
	if manifest.is_empty():
		return {}
	var animation: Dictionary = manifest.animations[current_state]
	return {
		"visual_id": manifest.visual_id,
		"state": current_state,
		"direction": current_direction,
		"frame_index": frame_index,
		"frame_count": int(animation.frame_count),
		"duration_ms": get_current_duration_ms(),
		"loop": bool(animation.loop),
		"anchor": get_anchor(),
		"layers": get_active_layers(),
	}


func _apply_state_textures() -> void:
	var files: Dictionary = manifest.animations[current_state].layer_files
	body.texture = _load_texture(files.body)
	hair.texture = _load_texture(files.hair)
	outfit.texture = _load_texture(files.outfit)
	var equipment_texture := _load_texture(files.equipment_test)
	equipment_back.texture = equipment_texture
	equipment_front.texture = equipment_texture


func _load_texture(path: String) -> Texture2D:
	if not _textures.has(path):
		_textures[path] = load(path)
	return _textures[path]


func _apply_frame() -> void:
	if manifest.is_empty():
		return
	var animation: Dictionary = manifest.animations[current_state]
	var row := int(animation.direction_rows[current_direction])
	var canvas := get_canvas_size()
	var region := Rect2(frame_index * canvas.x, row * canvas.y, canvas.x, canvas.y)
	var anchor := get_anchor()
	var layer_position := Vector2(canvas.x * 0.5 - anchor.x, canvas.y * 0.5 - anchor.y)
	for sprite in [body, hair, outfit, equipment_back, equipment_front]:
		sprite.region_enabled = true
		sprite.region_rect = region
		sprite.position = layer_position
	_apply_equipment_occlusion()
	frame_changed.emit(current_state, current_direction, frame_index)


func _apply_equipment_occlusion() -> void:
	if manifest.is_empty():
		return
	var definition: Dictionary = manifest.layers.equipment_test
	var stack := String(definition.direction_stack.get(current_direction, "front"))
	var enabled := equipment_visible and bool(definition.get("visible_on_character", true))
	equipment_back.visible = enabled and stack == "back"
	equipment_front.visible = enabled and stack == "front"
