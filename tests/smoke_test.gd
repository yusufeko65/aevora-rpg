extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	_assert(main_scene != null, "Main scene loads")
	var main := main_scene.instantiate()
	root.add_child(main)
	await process_frame

	var player := main.get_node("PrototypeZone/Player") as PlayerController
	var world := main.get_node("PrototypeZone") as PrototypeZone
	var npc := world.get_node("TestFarmer") as PrototypeNpc
	var npc_target := npc.get_node("InteractionTarget") as InteractionTarget
	var sign_target := world.get_node("RiverSign/InteractionTarget") as InteractionTarget
	var hud := main.get_node("DebugHud") as DebugHud

	_assert(player != null, "Reusable player is present")
	_assert(world.zone_id == "prototype.first_village_edge", "Zone uses a stable ID")
	_assert(npc.identity != null and npc.identity.stable_id == "npc.prototype.test_farmer", "NPC identity is data-driven")
	_assert(npc_target.is_in_group("interactable") and sign_target.is_in_group("interactable"), "NPC and object share the interaction contract")
	_assert(npc_target.interact(player).begins_with("Field Farmer:"), "NPC interaction returns its configured response")
	_assert(player.collision_layer == 2 and player.collision_mask == 1, "Player collision layers target world geometry")
	_assert(player.get_node("InteractionProbe").collision_mask == 4, "Interaction probe targets interactables only")
	_assert(player.get_node("Visual") is Sprite2D, "Player uses the DEV-002 sprite sheet")
	_assert(world.get_node("PlayerHome/Sprite") is Sprite2D, "Visual slice includes the player home")
	_assert(world.get_node("Bridge01") is Sprite2D, "Visual slice includes the river bridge")
	_assert(player.interaction_enter_radius == 44.0 and player.interaction_exit_radius == 56.0, "Interaction focus uses documented hysteresis radii")
	_assert(player.interaction_exit_radius >= player.interaction_enter_radius, "Interaction exit radius is not smaller than enter radius")
	_assert(world.has_node("WorldCollision/RiverWaterLeft") and world.has_node("WorldCollision/RiverWaterRight"), "River water has explicit full-depth blockers")
	_assert(world.has_node("WorldCollision/BridgeWestRail") and world.has_node("WorldCollision/BridgeEastRail"), "Bridge corridor has blocking side rails")
	_assert(world.has_node("WorldCollision/CropRowNorth") and world.has_node("WorldCollision/CropRowMiddle") and world.has_node("WorldCollision/CropRowSouth"), "Garden uses multiple crop-row colliders")
	_assert(world.get_node("TreeTrunks/TreeNorthWest").shape is CapsuleShape2D, "Tree collision represents the trunk/root footprint")

	player.global_position = npc_target.global_position
	player.interaction_completed.emit(npc_target, "Owned NPC message")
	await process_frame
	_assert(hud.get_active_message_source() == npc_target, "Interaction message retains its source target")
	player.global_position = npc_target.global_position + Vector2(player.interaction_exit_radius + 1.0, 0.0)
	await process_frame
	_assert(hud.get_active_message_source() == null, "NPC message closes immediately outside exit radius")

	player.global_position = sign_target.global_position
	player.interaction_completed.emit(sign_target, "Owned sign message")
	await process_frame
	_assert(hud.get_active_message_source() == sign_target, "Sign message uses the same owned-session contract")
	sign_target.enabled = false
	await process_frame
	_assert(hud.get_active_message_source() == null, "Message closes safely when its source becomes non-interactable")

	var temporary_source := InteractionTarget.new()
	temporary_source.global_position = player.global_position
	world.add_child(temporary_source)
	player.interaction_completed.emit(temporary_source, "Temporary source")
	await process_frame
	_assert(hud.get_active_message_source() == temporary_source, "Temporary interaction source opens one shared message panel")
	temporary_source.queue_free()
	await process_frame
	await process_frame
	_assert(hud.get_active_message_source() == null, "Freed interaction source closes without a crash")

	print("DEV-003 smoke test passed")
	quit(0)


func _assert(condition: bool, description: String) -> void:
	if condition:
		return
	push_error("Smoke test failed: %s" % description)
	quit(1)
