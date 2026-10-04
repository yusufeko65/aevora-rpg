extends Node2D

var animation := "idle"
var textures: Array[ImageTexture] = []
var geometry: Array = []

func set_animation(value: String) -> void:
	animation = value
	textures.clear()
	geometry.clear()
	var contract = load("res://systems/art_r001/asset_contract.gd")
	for frame in range(4 if animation == "idle" else 6):
		var path := "res://art/rnd/art_r001/candidates/sprite_studio/frames/art-r001-down-%s_%02d.png" % [animation,frame+1]
		var image := Image.new()
		assert(image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK)
		assert(image.get_size() == Vector2i(64,64))
		textures.append(ImageTexture.create_from_image(image))
		var measured: Dictionary = contract.measure_cell(image,Vector2i.ZERO)
		measured["frame"] = frame
		measured["path"] = path
		var hasher := HashingContext.new()
		hasher.start(HashingContext.HASH_SHA256)
		hasher.update(image.get_data())
		measured["pixel_sha256"] = hasher.finish().hex_encode()
		geometry.append(measured)
	queue_redraw()

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_animation(animation)

func text_at(at: Vector2, message: String, font_size: int = 12) -> void:
	draw_string(ThemeDB.fallback_font,at,message,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color.WHITE)

func frame_at(frame: int, at: Vector2, factor: float) -> void:
	var canvas := Rect2(at,Vector2(64,64)*factor)
	draw_texture_rect(textures[frame],canvas,false)
	draw_rect(canvas,Color("6abbea"),false,1)
	var pivot := at+Vector2(32,44)*factor
	draw_line(pivot-Vector2(7,0),pivot+Vector2(7,0),Color("ff657e"),1)
	draw_line(pivot-Vector2(0,7),pivot+Vector2(0,7),Color("ff657e"),1)
	text_at(at+Vector2(2,-4),"frame %d" % frame,10)

func _draw() -> void:
	if textures.is_empty():
		return
	draw_rect(Rect2(0,0,640,360),Color("1e2936"))
	text_at(Vector2(16,25),"ART-R001  |  native %s source  |  DOWN ONLY" % animation,17)
	text_at(Vector2(16,45),"7 FPS source; comparison 150ms. Other directions NOT generated. Root target (32,44).",11)
	if animation == "idle":
		text_at(Vector2(16,67),"1x logical",11)
		for i in range(4):
			frame_at(i,Vector2(40+i*100,90),1)
		text_at(Vector2(16,185),"2x inspection — rigid-part motion is an R&D result, not final art approval",11)
		for i in range(4):
			frame_at(i,Vector2(40+i*142,208),2)
	else:
		text_at(Vector2(16,68),"2x inspection / six source frames / fixed complete 64px canvases",11)
		for i in range(6):
			frame_at(i,Vector2(60+(i%3)*190,90+(i/3)*142),2)
