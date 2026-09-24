extends Node2D

@onready var world: PrototypeZone = $PrototypeZone
@onready var player: PlayerController = $PrototypeZone/Player


func _ready() -> void:
	player.global_position = world.get_node("PlayerSpawn").global_position
