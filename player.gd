extends CharacterBody2D

@export var respawn_position: Vector2
@onready var visual_pivot := $VisualPivot as Node2D
@onready var anim = $VisualPivot/AnimatedSprite2D
@onready var death_label: Label = $"../DeathScreen/Root/DeathMessage"
var dead := false
@onready var pit_layers: Array[TileMapLayer] = [
	$"../FloorPit1" as TileMapLayer,
	$"../FloorPit2" as TileMapLayer,
	$"../FloorPit3" as TileMapLayer,
]
@export var feet_offset_y := 8.0

const SPEED := 300.0
const JUMP_VELOCITY := -650.0

var facing := 1.0 # 1 = right, -1 = left

func _ready() -> void:
	print("pit_layers:", pit_layers)
	if respawn_position == Vector2.ZERO:
		respawn_position = global_position
	death_label.visible = false

func _physics_process(delta: float) -> void:
	if dead:
		# No player control, but still fall:
		velocity.x = 0.0
		velocity += get_gravity() * delta
		move_and_slide()

		if Input.is_action_just_pressed("restart"):
			restart()
		return

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0.0:
		facing = sign(direction)
	visual_pivot.scale.x = facing

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()


	if not dead and velocity.y > 0.0 and _feet_is_over_pit():
		die()
		return

	# Animation
	if not is_on_floor():
		anim.play("jump")
	elif abs(velocity.x) > 1.0:
		anim.play("run")
	else:
		anim.play("idle")
func die() -> void:
	if dead: return
	dead = true
	velocity = Vector2.ZERO
	death_label.text = "You died. Press R to restart."
	death_label.visible = true
	
func _on_death_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("deathzone"):
		die()
		
func restart() -> void:
	dead = false
	death_label.visible = false
	global_position = respawn_position
	velocity = Vector2.ZERO
	
func _feet_is_over_pit() -> bool:
	var feet_global := global_position + Vector2(0, feet_offset_y)

	for pit in pit_layers:
		if pit == null:
			continue
		var cell := pit.local_to_map(pit.to_local(feet_global))
		if pit.get_cell_source_id(cell) != -1:
			return true
	return false
