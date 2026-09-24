extends Node2D

@onready var world: PrototypeZone = $PrototypeZone
@onready var player: PlayerController = $Player


func _ready() -> void:
	player.global_position = world.get_node("PlayerSpawn").global_position
