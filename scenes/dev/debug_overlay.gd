extends CanvasLayer

@export var world_path: NodePath
@onready var world: Node2D = get_node(world_path)
@onready var player: PlayerV2 = world.get_node("Actors/Player")
var panel: Label
var hint: Label
var debug_visible := false

func _ready() -> void:
	panel = Label.new()
	panel.position = Vector2(10, 10)
	panel.add_theme_font_size_override("font_size", 12)
	panel.add_theme_color_override("font_shadow_color", Color.BLACK)
	panel.add_theme_constant_override("shadow_offset_x", 1)
	panel.add_theme_constant_override("shadow_offset_y", 1)
	add_child(panel)
	hint = Label.new()
	hint.position = Vector2(10, 327)
	hint.add_theme_font_size_override("font_size", 10)
	hint.text = "WASD  Move / Direction    Shift  Run    Tab  Equip / Unequip Sword\nLMB / J  Attack    F1  Debug Info    F2  Debug Guides    F3  Shadow Compare"
	hint.add_theme_color_override("font_shadow_color", Color.BLACK)
	hint.add_theme_constant_override("shadow_offset_y", 1)
	add_child(hint)

func _process(_delta: float) -> void:
	panel.visible = debug_visible
	if not debug_visible:
		return
	var v := player.visual
	var source_column := int(v.source_region(v.current_layers()[-1]).position.x / 64)
	panel.text = "CRAFTPIX / development source reference\n%s %s / row %d / step %d of %d / source col %d\n%.0f ms / %.1f animation fps / %d render fps\npos (%.2f, %.2f) / walk %.0f / run %.0f px/s\n64x64 native / pivot (32,44) / feet collider 10x6\n%s / shadow %s (Review) / ground 16 source, 32 logical" % [
		v.state, v.direction, v.source_row(), v.frame_index + 1, v.mapping.states[v.state].frame_count,
		source_column, v.duration_ms(), 1000.0 / v.duration_ms(), Engine.get_frames_per_second(),
		player.position.x, player.position.y, player.walk_speed, player.run_speed,
		"Sword back/body/front/head" if v.sword else "Unarmed", "B separate source" if v.separate_shadow or v.sword else "A baked source"]
	var boar := world.get_node("Actors/BoarPreview")
	panel.text += "\nSword equipped %s / attack active %s / Boar %s %s" % [v.sword, player.attacking, boar.ambient_state, boar.visual.direction]

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_F1:
			debug_visible = not debug_visible
		KEY_F2:
			var enabled := not player.visual.guides
			player.visual.guides = enabled
			world.get_node("Actors/BoarPreview/SourceSprite").guides = enabled
			get_tree().debug_collisions_hint = enabled
		KEY_F3:
			player.visual.separate_shadow = not player.visual.separate_shadow
		KEY_TAB:
			player.toggle_sword()
