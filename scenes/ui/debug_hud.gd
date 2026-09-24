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


func _ready() -> void:
	player.interaction_completed.connect(_show_message)
	debug_panel.visible = false
	message_label.text = ""
	message_panel.visible = false
	_message_time_left = 0.0


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_debug"):
		debug_panel.visible = not debug_panel.visible
	var target_name := "none"
	if is_instance_valid(player.focused_target):
		target_name = player.focused_target.get_interaction_prompt()
	debug_label.text = "DEV-002 visual slice\nZone: %s\nPlayer: (%.0f, %.0f)\nFocus: %s\nFPS: %d\nRenderer: Compatibility" % [world.zone_id, player.global_position.x, player.global_position.y, target_name, Engine.get_frames_per_second()]
	var prompt := player.get_interaction_prompt()
	prompt_label.text = "[E] %s" % prompt if not prompt.is_empty() else ""
	prompt_panel.visible = not prompt.is_empty()
	if _message_time_left > 0.0:
		_message_time_left -= delta
	elif not message_label.text.is_empty():
		message_label.text = ""
	message_panel.visible = not message_label.text.is_empty()


func _show_message(message: String) -> void:
	message_label.text = message
	message_panel.visible = true
	_message_time_left = 4.0
