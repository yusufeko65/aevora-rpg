class_name DebugHud
extends CanvasLayer

@export var player_path: NodePath
@export var world_path: NodePath

@onready var player: PlayerController = get_node(player_path)
@onready var world: PrototypeZone = get_node(world_path)
@onready var debug_label: Label = $Root/DebugPanel/Margin/DebugLabel
@onready var prompt_label: Label = $Root/PromptPanel/Margin/PromptLabel
@onready var message_label: Label = $Root/MessagePanel/Margin/MessageLabel
@onready var debug_panel: Control = $Root/DebugPanel
@onready var prompt_panel: Control = $Root/PromptPanel
@onready var message_panel: Control = $Root/MessagePanel

var _message_time_left := 0.0
var _message_source: InteractionTarget
var _collision_debug_enabled := false


func _ready() -> void:
	player.interaction_completed.connect(_show_message)
	player.focused_target_changed.connect(_on_focused_target_changed)
	debug_panel.visible = false
	message_label.text = ""
	message_panel.visible = false
	_message_time_left = 0.0


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_debug"):
		debug_panel.visible = not debug_panel.visible
	if Input.is_action_just_pressed("toggle_collision_debug"):
		_collision_debug_enabled = not _collision_debug_enabled
		get_tree().debug_collisions_hint = _collision_debug_enabled
	var target_name := "none"
	if is_instance_valid(player.focused_target):
		target_name = player.focused_target.get_interaction_prompt()
	var source_name := "none"
	if is_instance_valid(_message_source):
		source_name = _message_source.get_interaction_prompt()
	debug_label.text = "DEV-003 stabilization\nZone: %s\nPlayer: (%.0f, %.0f)\nFocus: %s\nSession: %s\nRange: %.0f / %.0f\nCollision [F2]: %s\nFPS: %d" % [world.zone_id, player.global_position.x, player.global_position.y, target_name, source_name, player.interaction_enter_radius, player.interaction_exit_radius, "on" if _collision_debug_enabled else "off", Engine.get_frames_per_second()]
	var prompt := player.get_interaction_prompt()
	prompt_label.text = "[E] %s" % prompt if not prompt.is_empty() else ""
	prompt_panel.visible = not prompt.is_empty()
	if not _is_message_session_valid():
		_close_message()
	elif _message_time_left > 0.0:
		_message_time_left -= delta
	else:
		_close_message()
	message_panel.visible = not message_label.text.is_empty()


func _show_message(source: InteractionTarget, message: String) -> void:
	_message_source = source
	message_label.text = message
	message_panel.visible = true
	_message_time_left = 4.0


func _on_focused_target_changed(target: InteractionTarget) -> void:
	if is_instance_valid(_message_source) and target != _message_source:
		_close_message()


func _is_message_session_valid() -> bool:
	if message_label.text.is_empty() or not is_instance_valid(_message_source):
		return false
	if not _message_source.can_interact(player):
		return false
	return player.global_position.distance_to(_message_source.global_position) <= player.interaction_exit_radius


func _close_message() -> void:
	message_label.text = ""
	message_panel.visible = false
	_message_source = null
	_message_time_left = 0.0


func get_active_message_source() -> InteractionTarget:
	return _message_source
