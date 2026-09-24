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

var _message_time_left := 0.0


func _ready() -> void:
	player.interaction_completed.connect(_show_message)
	message_label.text = "WASD to move • E or Space to interact • F3 debug"
	_message_time_left = 5.0


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_debug"):
		debug_panel.visible = not debug_panel.visible
	var target_name := "none"
	if is_instance_valid(player.focused_target):
		target_name = player.focused_target.get_interaction_prompt()
	debug_label.text = "Prototype 0.1\nZone: %s\nPlayer: (%.0f, %.0f)\nFocus: %s\nRenderer: Compatibility" % [world.zone_id, player.global_position.x, player.global_position.y, target_name]
	var prompt := player.get_interaction_prompt()
	prompt_label.text = "[E] %s" % prompt if not prompt.is_empty() else ""
	if _message_time_left > 0.0:
		_message_time_left -= delta
	elif not message_label.text.is_empty():
		message_label.text = ""


func _show_message(message: String) -> void:
	message_label.text = message
	_message_time_left = 4.0
