extends SceneTree

var directions := [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN,Vector2(-1,-1).normalized(),Vector2(1,-1).normalized(),Vector2(-1,1).normalized(),Vector2(1,1).normalized()]
const ORIGIN := Vector2(640,432)
var checks := 0
var failures := 0
var finish_count := 0
var observations: Array = []
var player: PlayerV2
var boar: CharacterBody2D

func _initialize() -> void:
	call_deferred("run_tests")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func feet(body: CharacterBody2D) -> Rect2:
	var collider := body.get_node("CollisionShape2D") as CollisionShape2D
	return Rect2(collider.global_position - collider.shape.size/2,collider.shape.size)

func penetration() -> float:
	var intersection := feet(player).intersection(feet(boar))
	return maxf(0,intersection.size.x) * maxf(0,intersection.size.y)

func hits(body: CharacterBody2D, other: Node) -> bool:
	for index in range(body.get_slide_collision_count()):
		if body.get_slide_collision(index).get_collider() == other:
			return true
	return false

func release_input() -> void:
	for action: String in ["move_left","move_right","move_up","move_down","run","attack_primary"]:
		Input.action_release(action)

func hold_direction(axis: Vector2, running: bool) -> void:
	if axis.x != 0:
		Input.action_press("move_right" if axis.x > 0 else "move_left")
	if axis.y != 0:
		Input.action_press("move_down" if axis.y > 0 else "move_up")
	if running:
		Input.action_press("run")

func reset_actors(player_at: Vector2, boar_at: Vector2) -> void:
	release_input()
	if player.attacking:
		player.visual.advance(2)
	player.position = player_at
	player.velocity = Vector2.ZERO
	player.visual.set_pose("idle","down")
	boar.position = boar_at
	boar.velocity = Vector2.ZERO
	boar.ambient_state = "idle"
	boar.remaining = 10
	boar.visual.set_pose("idle","down")

func run_tests() -> void:
	var main: Node2D = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	var world: Node2D = main.get_node("TestWorld")
	player = world.get_node("Actors/Player")
	boar = world.get_node("Actors/BoarPreview")
	player.set_physics_process(false)
	player.visual.set_process(false)
	boar.set_physics_process(false)
	boar.visual.set_process(false)
	# The Player's earlier signal receiver immediately changes the current pose.
	# Count the completion event itself, not that subsequently changed pose.
	player.visual.animation_finished.connect(func(_state: String): finish_count += 1)
	check(player.collision_layer == 1 and player.collision_mask == 6,"Explicit Player: layer1, mask Environment+Fauna")
	check(boar.collision_layer == 4 and boar.collision_mask == 3,"Explicit Fauna: layer4, mask Player+Environment")
	for index in range(3):
		check(ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % (index+1)) == ["Player","Environment","Fauna"][index],"Named editor physics contract")
	var static_count := 0
	var static_shapes := 0
	var solid_count := 0
	for body: StaticBody2D in world.find_children("*","StaticBody2D",true,false):
		static_count += 1
		var shapes := body.find_children("*","CollisionShape2D",true,false)
		static_shapes += shapes.size()
		if not shapes.is_empty():
			solid_count += 1
		check(body.collision_layer == 2,"Environment-only layer: " + str(body.get_path()))
	check(static_count == 49 and solid_count == 47 and static_shapes == 52,"All active environment audited:42 fence pieces,5 trees,house,boundaries;52 unchanged shapes")
	check(feet(player).size == Vector2(10,6) and player.get_node("CollisionShape2D").position == Vector2(0,-1),"Unchanged Player feet")
	check(feet(boar).size == Vector2(16,8) and boar.get_node("CollisionShape2D").position == Vector2(0,-2),"Unchanged Boar feet")
	check(player.visual.mapping.pivot == [32.0,44.0],"Unchanged Player pivot")
	check(world.get_node("Actors").y_sort_enabled and player.get_parent() == boar.get_parent(),"Actor roots share dynamic Y-sort")
	check(player.z_index == 0 and boar.z_index == 0 and player.get_node("VisualRoot").position == Vector2.ZERO and boar.visual.position == Vector2.ZERO,"Rendering roots/z-order untouched")
	await physics_frame
	# Every step checks actual feet occupancy; diagonal sliding is legal, penetration is not.
	for running: bool in [false,true]:
		for axis: Vector2 in directions:
			reset_actors(ORIGIN-axis*32,ORIGIN)
			await physics_frame
			player.visual.sword = false
			hold_direction(axis,running)
			var before := player.position
			var touched := false
			var slides := 0
			for tick in range(90):
				player._physics_process(1.0/60.0)
				touched = touched or hits(player,boar)
				if hits(player,boar):
					slides += 1
				check(penetration() < 0.001,"Player %s direction%s tick%d has no penetration" % ["run" if running else "walk",str(axis),tick])
			var progress := (player.position-before).dot(axis)
			var cardinal := axis.x == 0 or axis.y == 0
			check(touched and progress > 1 and progress < (32 if cardinal else (168 if running else 72)-1),"Player contact blocks direct crossing or deflects diagonal movement without penetration")
			observations.append({"case":"player_run" if running else "player_walk","direction":str(axis),"progress":progress,"contact_ticks":slides,"player_position":str(player.position),"boar_position":str(boar.position),"penetration_area":penetration()})
			release_input()
	for axis: Vector2 in directions:
		reset_actors(ORIGIN,ORIGIN-axis*28)
		await physics_frame
		boar.target = ORIGIN
		boar.ambient_state = "walk"
		boar.remaining = 10
		var before := boar.position
		var touched := false
		for tick in range(90):
			boar._physics_process(1.0/60.0)
			touched = touched or hits(boar,player)
			check(penetration() < 0.001,"Ambient Boar direction%s tick%d has no penetration" % [str(axis),tick])
		var progress := (boar.position-before).dot(axis)
		check(touched and progress > 1 and progress < 28,"Ambient Boar reaches but cannot pass Player")
		check((boar.ambient_state == "idle" and boar.velocity.is_zero_approx()) or (boar.ambient_state == "walk" and boar.velocity.length() <= boar.walk_speed + 0.01 and boar.visual.direction == PlayerV2.facing_for(boar.velocity,boar.visual.direction)),"Existing Boar may idle or slide with facing derived from actual velocity")
		observations.append({"case":"boar_walk","direction":str(axis),"progress":progress,"state":boar.ambient_state,"velocity":str(boar.velocity),"player_position":str(player.position),"boar_position":str(boar.position),"penetration_area":penetration()})
	for running: bool in [false,true]:
		for axis: Vector2 in directions:
			reset_actors(ORIGIN-axis*28,ORIGIN)
			await physics_frame
			player.visual.sword = true
			var before := player.position
			var prior_finishes := finish_count
			var family := "run_attack" if running else "walk_attack"
			var ticks := 72 if running else 54
			var touched := false
			check(player.start_attack(axis,running) and player.visual.state == family,"Correct moving attack starts")
			for tick in range(ticks):
				player._physics_process(1.0/60.0)
				touched = touched or hits(player,boar)
				player.visual.advance(1.0/60.0)
				check(penetration() < 0.001,"Moving attack never penetrates Fauna")
				if tick < ticks-1:
					check(player.attacking and player.visual.state == family and finish_count == prior_finishes,"Blocked attack still plays full source duration")
			var progress := (player.position-before).dot(axis)
			var cardinal := axis.x == 0 or axis.y == 0
			check(touched and progress > 1 and progress < (28 if cardinal else (134.4 if running else 43.2)-1),"Moving attack reaches contact; direct motion blocks, diagonal motion may slide without penetration")
			check(not player.attacking and player.visual.state == "idle" and finish_count == prior_finishes+1,"Blocked attack finishes once and returns to released-input Sword Idle")
			player.visual.advance(2)
			check(finish_count == prior_finishes+1,"Completion not repeated after contact")
			observations.append({"case":family,"direction":str(axis),"progress":progress,"finishes":finish_count-prior_finishes,"penetration_area":penetration()})
	# Retained controller input chooses current live locomotion after a blocked attack.
	reset_actors(ORIGIN-Vector2.RIGHT*28,ORIGIN)
	await physics_frame
	player.start_attack(Vector2.RIGHT,true)
	Input.action_press("move_left")
	for tick in range(72):
		player._physics_process(1.0/60.0)
		player.visual.advance(1.0/60.0)
	check(not player.attacking and player.visual.state == "walk" and player.visual.direction == "left","Blocked attack completion reevaluates current live input")
	release_input()
	# Environment regression for both actors; widened roam rectangle is a test-only
	# fixture so original ambient clamping cannot teleport probes out of the yard.
	boar.roam_area = Rect2(0,0,960,640)
	var fixtures := [
		{"name":"house","at":Vector2(488,326),"axis":Vector2.UP},
		{"name":"fence","at":Vector2(488,390),"axis":Vector2.UP},
		{"name":"tree","at":Vector2(336,398),"axis":Vector2.UP},
		{"name":"boundary_left","at":Vector2(32,500),"axis":Vector2.LEFT},
		{"name":"boundary_right","at":Vector2(928,500),"axis":Vector2.RIGHT},
		{"name":"boundary_top","at":Vector2(800,32),"axis":Vector2.UP},
		{"name":"boundary_bottom","at":Vector2(800,608),"axis":Vector2.DOWN}]
	for fixture: Dictionary in fixtures:
		reset_actors(fixture.at,ORIGIN)
		await physics_frame
		hold_direction(fixture.axis,true)
		var before := player.position
		var static_contact := false
		for tick in range(120):
			player._physics_process(1.0/60.0)
			for index in range(player.get_slide_collision_count()):
				static_contact = static_contact or player.get_slide_collision(index).get_collider() is StaticBody2D
		check(static_contact and player.position.distance_to(before) < 40,"Player still blocked by " + fixture.name)
		release_input()
		reset_actors(Vector2(800,550),fixture.at)
		await physics_frame
		boar.target = fixture.at + fixture.axis*100
		boar.ambient_state = "walk"
		boar.remaining = 10
		before = boar.position
		static_contact = false
		for tick in range(120):
			boar._physics_process(1.0/60.0)
			for index in range(boar.get_slide_collision_count()):
				static_contact = static_contact or boar.get_slide_collision(index).get_collider() is StaticBody2D
		check(static_contact and boar.position.distance_to(before) < 40,"Boar still blocked by " + fixture.name)
	check(not FileAccess.file_exists("res://CONTEXT.md"),"No CONTEXT.md introduced")
	var evidence := {"checks":checks,"failures":failures,"static_bodies":static_count,"solid_static_bodies":solid_count,"static_shapes":static_shapes,"actor_contacts":observations}
	var file := FileAccess.open("res://docs/reports/dev-r001-3-physics-evidence.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(evidence,"\t") + "\n")
	print("DEV-R001.3 %s: %d checks, %d failures; actor matrix, all static bodies,40 directional actor contacts, full attack completion, Y-sort contract and both-actor environment/boundaries." % ["PASS" if failures == 0 else "FAIL",checks,failures])
	main.free()
	quit(0 if failures == 0 else 1)
