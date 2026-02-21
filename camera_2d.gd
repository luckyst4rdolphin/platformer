extends Camera2D

@onready var layers: Array[TileMapLayer] = [
	$"../../Background1" as TileMapLayer,
	$"../../Background2" as TileMapLayer,
	$"../../Background3" as TileMapLayer,
]

func _ready() -> void:
	setup_camera_limits()

func _layer_used_rect_global_pixels(l: TileMapLayer) -> Rect2:
	var r: Rect2i = l.get_used_rect()
	if r.size == Vector2i.ZERO:
		return Rect2() # empty

	# Top-left corner in global pixels
	var tl_local: Vector2 = l.map_to_local(r.position)
	var tl_global: Vector2 = l.to_global(tl_local)

	# Bottom-right corner in global pixels (use position+size)
	var br_local: Vector2 = l.map_to_local(r.position + r.size)
	var br_global: Vector2 = l.to_global(br_local)

	# Build a normalized rect (handles any ordering)
	var left   := minf(tl_global.x, br_global.x)
	var right  := maxf(tl_global.x, br_global.x)
	var top    := minf(tl_global.y, br_global.y)
	var bottom := maxf(tl_global.y, br_global.y)

	return Rect2(Vector2(left, top), Vector2(right - left, bottom - top))

func setup_camera_limits() -> void:
	var have_any := false
	var combined := Rect2()

	for l in layers:
		if l == null: continue
		var g := _layer_used_rect_global_pixels(l)
		if g.size == Vector2.ZERO: continue
		if not have_any:
			combined = g
			have_any = true
		else:
			combined = combined.merge(g)

	if not have_any:
		push_warning("No tiles found in any background layers.")
		return

	limit_left   = int(floor(combined.position.x))
	limit_top    = int(floor(combined.position.y))
	limit_right  = int(ceil(combined.position.x + combined.size.x))
	limit_bottom = int(ceil(combined.position.y + combined.size.y))
