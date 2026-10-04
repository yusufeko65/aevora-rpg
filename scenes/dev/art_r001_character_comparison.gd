extends Node2D

const Contract = preload("res://systems/art_r001/asset_contract.gd")
const DIRECTIONS := ["down","left","right","up"]
const PREVIEW_SCALES := [1.0,2.0]
const ROOTS := [[Vector2(96,174),Vector2(224,174)],[Vector2(400,218),Vector2(536,218)]]
const TARGET_PIVOT := Vector2(32,44)
var benchmark: Dictionary = {}
var candidate: Dictionary = {}
var validation: Dictionary = {}
var textures: Dictionary = {}
var native_frames: Dictionary = {}
var preview_native_sources := true
var state := "idle"
var direction := "down"
var paused := false
var root_guides := true
var canvas_guides := true
var alternate_ground := false
var elapsed := 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	benchmark = Contract.read_json("res://data/source_mapping/craftpix.json").human
	candidate = Contract.read_json(Contract.META)
	validation = Contract.validate(candidate)
	for animation: String in ["idle","walk"]:
		textures["benchmark_"+animation] = load_png(benchmark.states[animation].unarmed_full.file)
		textures["candidate_"+animation] = load_png(candidate.get("states",{}).get(animation,{}).get("file","")) if validation.status == "PASS" else null
	for facing: String in candidate.get("preview_masters", {}):
		textures["master_"+facing] = load_png(candidate.preview_masters[facing])
	var sources := Contract.read_json("res://art/rnd/art_r001/metadata/source_frames.json")
	for facing: String in DIRECTIONS:
		native_frames[facing] = {}
		for animation: String in ["idle","walk"]:
			var frames: Array[ImageTexture] = []
			var expected := 4 if animation == "idle" else 6
			for path: String in sources.get("frames",{}).get(facing,{}).get(animation,[]):
				var image := Image.new()
				if not FileAccess.file_exists(path) or image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK or image.get_size() != Vector2i(64,64):
					break
				var cell := Contract.measure_cell(image,Vector2i.ZERO)
				if cell.semi_alpha_pixels != 0 or cell.opaque_pixels == 0 or cell.transparent_pixels == 0 or mini(mini(cell.margin_left,cell.margin_right),mini(cell.margin_top,cell.margin_bottom)) < 1:
					break
				frames.append(ImageTexture.create_from_image(image))
			if frames.size() == expected:
				native_frames[facing][animation] = frames
	queue_redraw()

func load_png(path: String) -> ImageTexture:
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _process(delta: float) -> void:
	if not paused:
		elapsed += delta
		queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	match key:
		KEY_1: state = "idle"; elapsed = 0
		KEY_2: state = "walk"; elapsed = 0
		KEY_DOWN: direction = "down"
		KEY_LEFT: direction = "left"
		KEY_RIGHT: direction = "right"
		KEY_UP: direction = "up"
		KEY_SPACE: paused = not paused
		KEY_F1: root_guides = not root_guides
		KEY_F2: canvas_guides = not canvas_guides
		KEY_F3: alternate_ground = not alternate_ground
	queue_redraw()

func frame_region(is_candidate: bool) -> Rect2:
	var rows: Dictionary = candidate.direction_rows if is_candidate else benchmark.direction_rows
	var row := int(rows[direction])
	var column := 0
	if is_candidate:
		var spec: Dictionary = candidate.states[state]
		column = int(elapsed*1000/float(spec.duration_ms)) % int(spec.frames)
	else:
		var spec: Dictionary = benchmark.states[state].unarmed_full.source_columns[str(row)]
		var duration := 0.0
		for ms: float in spec.durations_ms:
			duration += ms
		var phase := fmod(elapsed*1000,duration)
		for index in range(spec.columns.size()):
			if phase < float(spec.durations_ms[index]):
				column = int(spec.columns[index])
				break
			phase -= float(spec.durations_ms[index])
	return Rect2(column*64,row*64,64,64)

func text_at(at: Vector2, message: String, size_px: int = 12, color := Color("e6e7eb")) -> void:
	draw_string(ThemeDB.fallback_font,at,message,HORIZONTAL_ALIGNMENT_LEFT,-1,size_px,color)

func candidate_preview_mode() -> String:
	if validation.status == "PASS":
		return "VALIDATED SHEET"
	if preview_native_sources and native_frames.get(direction,{}).has(state):
		return "NATIVE %s ONLY" % direction.to_upper()
	return "MASTER ONLY"

func _draw() -> void:
	if benchmark.is_empty():
		return
	draw_rect(Rect2(0,0,640,360),Color("151b25"))
	text_at(Vector2(16,25),"ART-R001  |  original character pipeline R&D",18)
	text_at(Vector2(16,46),"%s / %s / %s  |  root (32,44) provisional" % [state,direction,"PAUSED" if paused else "PLAYING"])
	text_at(Vector2(16,65),"4-dir contract: %s  |  %s  |  Player unchanged" % [validation.status,candidate_preview_mode()],12,Color("ffc56e"))
	for panel in range(2):
		var light := Color("adb89c") if not alternate_ground else Color("d5c8ad")
		var dark := Color("334654") if not alternate_ground else Color("352d40")
		var ground: Color = light if panel == 0 else dark
		draw_rect(Rect2(16+panel*304,78,296,180),ground)
		text_at(Vector2(24+panel*304,96),"1x logical / light" if panel == 0 else "2x inspection / dark",12,Color("18252d") if panel == 0 else Color.WHITE)
		for side in range(2):
			var anchor: Vector2 = ROOTS[panel][side]
			var factor: float = PREVIEW_SCALES[panel]
			var canvas := Rect2(anchor-TARGET_PIVOT*factor,Vector2(64,64)*factor)
			var texture: ImageTexture = textures.get(("benchmark_" if side == 0 else "candidate_")+state)
			var source_only: bool = side == 1 and texture == null and preview_native_sources and native_frames.get(direction,{}).has(state)
			if source_only:
				var frames: Array = native_frames[direction][state]
				texture = frames[int(elapsed*1000/150.0) % frames.size()]
			var master_only := side == 1 and texture == null and textures.get("master_"+direction) != null
			if master_only:
				texture = textures["master_"+direction]
			if texture != null:
				draw_texture_rect_region(texture,canvas,Rect2(0,0,64,64) if master_only or source_only else frame_region(side == 1))
				if master_only or source_only:
					text_at(canvas.position+Vector2(0,-4),"MASTER ONLY" if master_only else "SOURCE ONLY",9,Color("6f3026") if panel == 0 else Color("ffc56e"))
			else:
				text_at(canvas.position+Vector2(2,24),"NO ART" if panel == 0 else "NO CANDIDATE",10,Color("6f3026") if panel == 0 else Color("ffc56e"))
				text_at(canvas.position+Vector2(2,38),"BLOCKED",9,Color("6f3026") if panel == 0 else Color("ffc56e"))
			if canvas_guides:
				draw_rect(canvas,Color("56cdfb"),false,1)
			if root_guides:
				draw_line(anchor-Vector2(8,0),anchor+Vector2(8,0),Color("ff657e"),1)
				draw_line(anchor-Vector2(0,8),anchor+Vector2(0,8),Color("ff657e"),1)
				draw_rect(Rect2(anchor+Vector2(-5,-4)*factor,Vector2(10,6)*factor),Color("ffdc69"),false,1)
			text_at(Vector2(anchor.x-50,249),"Craftpix benchmark" if side == 0 else "ARTCHAR-R001",10,Color("18252d") if panel == 0 else Color.WHITE)
	text_at(Vector2(16,280),"Same 64px canvas, root, camera and scale on both sides. Nearest sampling.")
	text_at(Vector2(16,300),"1 Idle   2 Walk   Arrows direction   Space pause/play")
	text_at(Vector2(16,320),"F1 root/feet target   F2 canvas   F3 contrast")
	text_at(Vector2(16,342),"1x logical = 2x native display; inspection = 4x native. No runtime promotion.",11)
