extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	_assert(main_scene != null, "Main scene loads")
	var main := main_scene.instantiate()
	root.add_child(main)
	await process_frame

	var player := main.get_node("Player") as PlayerController
	var world := main.get_node("PrototypeZone") as PrototypeZone
	var npc := world.get_node("RiverWarden") as PrototypeNpc
	var npc_target := npc.get_node("InteractionTarget") as InteractionTarget
	var sign_target := world.get_node("RiverSign/InteractionTarget") as InteractionTarget

	_assert(player != null, "Reusable player is present")
	_assert(world.zone_id == "prototype.first_village_edge", "Zone uses a stable ID")
	_assert(npc.identity != null and npc.identity.stable_id == "npc.prototype.river_warden", "NPC identity is data-driven")
	_assert(npc_target.is_in_group("interactable") and sign_target.is_in_group("interactable"), "NPC and object share the interaction contract")
	_assert(npc_target.interact(player).begins_with("River Warden:"), "NPC interaction returns its configured response")
	_assert(player.collision_layer == 2 and player.collision_mask == 1, "Player collision layers target world geometry")
	_assert(player.get_node("InteractionProbe").collision_mask == 4, "Interaction probe targets interactables only")

	print("DEV-001 smoke test passed")
	quit(0)


func _assert(condition: bool, description: String) -> void:
	if condition:
		return
	push_error("Smoke test failed: %s" % description)
	quit(1)
