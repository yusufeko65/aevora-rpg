extends Node2D

var state := "master"
var textures: Dictionary = {}
const DIRECTIONS := ["down","left","right","up"]

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_state(state)

func set_state(value: String) -> void:
	state = value
	textures.clear()
	for direction: String in DIRECTIONS:
		var frames: Array[ImageTexture] = []
		for i in range(1 if state == "master" else (4 if state == "idle" else 6)):
			var path := "res://art/rnd/art_r001/candidates/sprite_studio/master_%s.png" % direction if state == "master" else "res://art/rnd/art_r001/candidates/sprite_studio/frames/art-r001-%s-%s_%02d.png" % [direction,state,i+1]
			var image := Image.new()
			if not FileAccess.file_exists(path):
				frames.append(null)
				continue
			assert(image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK)
			assert(image.get_size() == Vector2i(64,64))
			frames.append(ImageTexture.create_from_image(image))
		textures[direction] = frames
	queue_redraw()

func text_at(at: Vector2, message: String, size: int = 11) -> void:
	draw_string(ThemeDB.fallback_font,at,message,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color.WHITE)

func frame_at(texture: ImageTexture, at: Vector2, factor: int) -> void:
	var canvas := Rect2(at,Vector2(64,64)*factor)
	if texture != null:
		draw_texture_rect(texture,canvas,false)
	draw_rect(canvas,Color("6abbea"),false,1)
	var pivot := at+Vector2(32,44)*factor
	draw_line(pivot-Vector2(5,0),pivot+Vector2(5,0),Color("ff657e"),1)
	draw_line(pivot-Vector2(0,5),pivot+Vector2(0,5),Color("ff657e"),1)

func _draw() -> void:
	if textures.is_empty():
		return
	draw_rect(Rect2(0,0,640,360),Color("1e2936"))
	text_at(Vector2(12,22),"ART-R001  |  %s  |  %s" % [state.to_upper(),"actual masters" if state == "master" else "INCOMPLETE native sources"],16)
	text_at(Vector2(12,40),"Root (32,44) unchanged. Directional feet offsets remain evidence; prototype, not final art.",11)
	if state == "master":
		text_at(Vector2(12,58),"1x logical above / 2x inspection below / down, left, right, up",11)
		for row in range(4):
			text_at(Vector2(40+row*148,80),DIRECTIONS[row],12)
			frame_at(textures[DIRECTIONS[row]][0],Vector2(40+row*148,88),1)
			frame_at(textures[DIRECTIONS[row]][0],Vector2(24+row*152,204),2)
	else:
		text_at(Vector2(12,57),"1x logical / source 7 FPS, target 150ms / complete sheets NOT exported",11)
		var count := 4 if state == "idle" else 6
		for row in range(4):
			if textures[DIRECTIONS[row]][0] == null:
				text_at(Vector2(12,101+row*71),"%s: BLOCKED — native rig failed; no frames rendered" % DIRECTIONS[row],12)
				continue
			text_at(Vector2(12,101+row*71),DIRECTIONS[row],12)
			for i in range(count):
				frame_at(textures[DIRECTIONS[row]][i],Vector2(112+i*82,67+row*71),1)
