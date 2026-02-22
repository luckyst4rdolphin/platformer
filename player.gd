extends CharacterBody2D

@export var respawn_position: Vector2
@export var feet_offset_y := 8.0

@onready var visual_pivot := $VisualPivot as Node2D
@onready var anim := $VisualPivot/AnimatedSprite2D as AnimatedSprite2D
@onready var death_label: Label = $"../DeathScreen/Root/DeathMessage"

@onready var pit_layers: Array[TileMapLayer] = [
	$"../FloorPit1" as TileMapLayer,
	$"../FloorPit2" as TileMapLayer,
	$"../FloorPit3" as TileMapLayer,
]

var dead := false
var facing := 1.0 # 1 = right, -1 = left

const SPEED := 300.0
const JUMP_VELOCITY := -650.0

# Wall slide / bounce
const WALL_SLIDE_SPEED := 140.0
const WALL_JUMP_Y := -650.0
const WALL_BOUNCE_X := 800.0

# Kicks back player when trying to wall jump
const AIR_ACCEL := 2400.0
const AIR_DECEL := 2000.0
const WALL_KICK_TIME := 0.10
const WALL_BLEND_TIME := 0.14
var wall_kick_t := 0.0

func _ready() -> void:
	if respawn_position == Vector2.ZERO:
		respawn_position = global_position
	death_label.visible = false

func _physics_process(delta: float) -> void:
	# Death: no input, but still fall
	if dead:
		velocity.x = 0.0
		velocity += get_gravity() * delta
		move_and_slide()

		if Input.is_action_just_pressed("restart"):
			restart()
		return

	# Timers
	wall_kick_t = maxf(0.0, wall_kick_t - delta)

	# Input
	var direction := Input.get_axis("ui_left", "ui_right")

	# Facing + flip
	if direction != 0.0:
		facing = sign(direction)
	visual_pivot.scale.x = facing

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Horizontal movement (smooth + wall-bounce recovery)
	var target_x := direction * SPEED

	# control: 0 during forced kick, then ramps to 1 during blend time
	var control := 1.0
	if wall_kick_t > 0.0:
		if wall_kick_t > WALL_BLEND_TIME:
			control = 0.0
		else:
			control = 1.0 - (wall_kick_t / WALL_BLEND_TIME)

	var blended_target := lerpf(velocity.x, target_x, control)
	var accel := AIR_ACCEL if abs(blended_target) > abs(velocity.x) else AIR_DECEL
	velocity.x = move_toward(velocity.x, blended_target, accel * delta)

	# Normal jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

	# Wall slide + wall bounce (only valid after move_and_slide)
	var on_wall := is_on_wall() and not is_on_floor()
	if on_wall:
		velocity.y = minf(velocity.y, WALL_SLIDE_SPEED)

		if Input.is_action_just_pressed("wall_jump"): # bind this to Space in Input Map
			var n := get_wall_normal() # only valid when is_on_wall() is true
			velocity.y = WALL_JUMP_Y
			velocity.x = n.x * WALL_BOUNCE_X
			wall_kick_t = WALL_KICK_TIME + WALL_BLEND_TIME

	# Pit death (only when falling)
	if velocity.y > 0.0 and _feet_is_over_pit():
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
	if dead:
		return
	dead = true
	velocity = Vector2.ZERO
	death_label.visible = true

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
