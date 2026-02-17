extends Camera2D

@export var tilemap: TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	setup_camera_limits()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func setup_camera_limits():
	if not tilemap:
		return
		
	var used_rect: Rect2i = tilemap.get_used_rect()
	var tile_map_size := tilemap.tile_set.get_tile_size()
	
	limit_left = used_rect.position.x
	limit_top = used_rect.position.y * tile_map_size.y
	limit_right = (used_rect.position.x + used_rect.size.x ) * tile_map_size.x
	limit_bottom = (used_rect.position.y + used_rect.size.y) * tile_map_size.y
