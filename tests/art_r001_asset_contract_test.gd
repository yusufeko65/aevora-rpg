extends SceneTree

const Contract = preload("res://systems/art_r001/asset_contract.gd")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func fixture(frames: int) -> Image:
	var image := Image.create(frames*64,256,false,Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for row in range(4):
		for frame in range(frames):
			image.fill_rect(Rect2i(frame*64+24,row*64+12,16,32),Color.TEAL)
	return image

func run_tests() -> void:
	var meta: Dictionary = Contract.read_json(Contract.META)
	check(Contract.metadata_errors(meta).is_empty(),"Real metadata schema/source references")
	for frames: int in [4,6]:
		var image := fixture(frames)
		var original_data := image.get_data()
		var result: Dictionary = Contract.inspect_sheet(image,frames)
		check(image.get_data() == original_data,"Measurements must never recenter/modify pixels")
		check(result.errors.is_empty(),"Valid in-memory fixed-grid fixture accepted (NOT candidate art)")
		var decoded := Image.new()
		check(decoded.load_png_from_buffer(image.save_png_to_buffer()) == OK,"Actual PNG encoding/decoding exercised")
		check(Contract.inspect_sheet(decoded,frames).errors.is_empty(),"Decoded PNG pixels validate")
		check(result.cells.size() == frames*4,"All four directions/all cells measured")
		for cell: Dictionary in result.cells:
			check(cell.bbox == [24,12,16,32],"Exact fixture bbox measurement")
			check(cell.bottommost_opaque_y == 43 and cell.bottom_delta_from_target_root == -1,"Root evidence measured without editing")
			check(cell.margin_left == 24 and cell.margin_right == 24 and cell.margin_top == 12,"Exact safety margins")
		check(not Contract.inspect_sheet(image,frames+1).errors.is_empty(),"Wrong dimensions/count/padding rejected")
		image.set_pixel(24,12,Color(1,1,1,0.5))
		check(not Contract.inspect_sheet(image,frames).errors.is_empty(),"Partial alpha rejected")
		image.fill(Color.WHITE)
		check(not Contract.inspect_sheet(image,frames).errors.is_empty(),"Opaque background/cell-edge ink rejected")
		image.fill(Color.TRANSPARENT)
		check(not Contract.inspect_sheet(image,frames).errors.is_empty(),"Blank rows/cells rejected")
	for field: String in ["pivot","direction_rows","states","frame_size","brief","provenance"]:
		var invalid := meta.duplicate(true)
		invalid.erase(field)
		check(not Contract.metadata_errors(invalid).is_empty(),"Missing " + field + " rejected")
	var outside := meta.duplicate(true)
	outside.pivot = [64,44]
	check(not Contract.metadata_errors(outside).is_empty(),"Out-of-frame pivot rejected")
	outside = meta.duplicate(true)
	outside.states.idle.file = "res://art/rnd/art_r001/exports/../../outside.png"
	check(not Contract.metadata_errors(outside).is_empty(),"Escaping export path rejected")
	for mutation: String in ["wrong_rows","wrong_count","wrong_timing","nonloop","extra_state","unknown_id"]:
		var invalid := meta.duplicate(true)
		match mutation:
			"wrong_rows": invalid.direction_rows.up = 0
			"wrong_count": invalid.states.walk.frames = 4
			"wrong_timing": invalid.states.idle.duration_ms = 100
			"nonloop": invalid.states.walk.loop = false
			"extra_state": invalid.states.run = invalid.states.walk
			"unknown_id": invalid.id = "CHAR-001"
		check(not Contract.metadata_errors(invalid).is_empty(),mutation + " rejected")
	var report: Dictionary = Contract.validate(meta)
	report["validator_self_tests"] = {"checks":checks,"failures":failures,"fixture_policy":"in-memory only; synthetic shapes never candidate exports"}
	var file := FileAccess.open("res://art/rnd/art_r001/review/asset-contract-report.json",FileAccess.WRITE)
	if file == null:
		push_error("Cannot write validation evidence")
		quit(1)
		return
	file.store_string(JSON.stringify(report,"\t") + "\n")
	print("ART-R001 validator self-tests: %d checks / %d failures; real candidate: %s" % [checks,failures,report.status])
	print(JSON.stringify(report))
	quit(1 if failures > 0 or report.status == "FAIL" else (2 if report.status == "BLOCKED" else 0))
