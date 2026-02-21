extends CharacterBody2D
@onready var visual_pivot := $VisualPivot as Node2D
@onready var anim = $VisualPivot/AnimatedSprite2D

const SPEED := 300.0
const JUMP_VELOCITY := -650.0

var facing := 1.0 # 1 = right, -1 = left

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Update facing only when there's input
	if direction != 0.0:
		facing = sign(direction)

	# Apply the visual flip from stored facing (persists on wall / no input)
	visual_pivot.scale.x = facing # 1 or -1

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal move
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()

	# Animation (one decision path)
	if not is_on_floor():
		anim.play("jump")
	elif abs(velocity.x) > 1.0:
		anim.play("run")
	else:
		anim.play("idle")
