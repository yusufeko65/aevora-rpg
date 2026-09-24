class_name PrototypeNpc
extends Node2D

@export var identity: NpcIdentity

@onready var interaction_target: InteractionTarget = $InteractionTarget


func _ready() -> void:
	if identity == null:
		return
	interaction_target.prompt_text = "Talk to %s" % identity.display_name
	interaction_target.response_text = "%s: %s" % [identity.display_name, identity.greeting]
