extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func press(scene: Node, key: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = true
	scene._unhandled_key_input(event)

func run_tests() -> void:
	var scene: Node2D = load("res://scenes/dev/art_r001_character_comparison.tscn").instantiate()
	root.add_child(scene)
	scene.set_process(false)
	await process_frame
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/main/main.tscn","Normal main scene unchanged")
	check(ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility","Compatibility renderer preserved")
	check(ProjectSettings.get_setting("display/window/size/viewport_width") == 640 and ProjectSettings.get_setting("display/window/size/viewport_height") == 360,"Logical baseline preserved")
	check(scene.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST,"Pixel-safe sampling")
	check(scene.PREVIEW_SCALES == [1.0,2.0],"Both sides share 1x/2x inspection scales")
	check(scene.TARGET_PIVOT == Vector2(32,44),"Provisional root unchanged")
	check(scene.get_node("Camera2D").position == Vector2(320,180),"Single shared camera")
	check(scene.textures.benchmark_idle != null and scene.textures.benchmark_walk != null,"Actual vendor benchmark PNGs load")
	check(scene.validation.status in ["PASS","BLOCKED"],"Invalid candidate cannot masquerade as valid")
	if scene.validation.status == "BLOCKED":
		check(scene.textures.candidate_idle == null and scene.textures.candidate_walk == null,"Missing art displayed honestly, no dummy replacement")
		for facing: String in scene.candidate.get("preview_masters",{}):
			check(scene.textures.get("master_"+facing) != null,"Actual supplied/generated master shown only under its own semantic direction")
		check(scene.native_frames.get("down",{}).get("idle",[]).size() == 4 and scene.native_frames.get("down",{}).get("walk",[]).size() == 6,"Actual down source loops previewed without claiming complete sheets")
		for facing: String in ["left","right","up"]:
			check(scene.native_frames[facing].is_empty(),"Missing native directions never relabeled from down")
		scene.direction = "down"
		check(scene.candidate_preview_mode() == "NATIVE DOWN ONLY","Incomplete source mode visibly labeled")
		scene.direction = "left"
		check(scene.candidate_preview_mode() == "MASTER ONLY","Other directions are neutral master-only, never fake motion")
	else:
		check(scene.textures.candidate_idle != null and scene.textures.candidate_walk != null,"Validated actual candidate textures load")
	for index in range(4):
		press(scene,[KEY_DOWN,KEY_LEFT,KEY_RIGHT,KEY_UP][index])
		check(scene.direction == scene.DIRECTIONS[index],"Arrow direction mapping")
		for key: int in [KEY_1,KEY_2]:
			press(scene,key)
			check(scene.state == ("idle" if key == KEY_1 else "walk"),"Only Idle/Walk selection")
			for candidate: bool in [false,true]:
				var region: Rect2 = scene.frame_region(candidate)
				check(region.size == Vector2(64,64) and region.position.y == index*64,"Explicit fixed-cell row mapping")
	scene.direction = "up"
	scene.state = "idle"
	scene.elapsed = 0.3
	check(scene.frame_region(false).position.x == 0,"Craftpix Up-idle repeated TMX columns preserved")
	press(scene,KEY_SPACE)
	check(scene.paused,"Pause toggle")
	press(scene,KEY_F1)
	press(scene,KEY_F2)
	press(scene,KEY_F3)
	check(not scene.root_guides and not scene.canvas_guides and scene.alternate_ground,"All guide/contrast controls")
	var echo := InputEventKey.new()
	echo.physical_keycode = KEY_SPACE
	echo.pressed = true
	echo.echo = true
	scene._unhandled_key_input(echo)
	check(scene.paused,"Keyboard repeat ignored")
	print("ART-R001 comparison: %d checks / %d failures" % [checks,failures])
	scene.free()
	quit(1 if failures > 0 else 0)
