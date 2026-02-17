extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -650.0

func _physics_process(delta: float) -> void:
	if velocity.x > 1:
		animated_sprite_2d.animation = "run"

	elif velocity.x < -1:
		animated_sprite_2d.animation = "runl"
	else:
		animated_sprite_2d.animation = "idle"
		
	var direction := Input.get_axis("ui_left", "ui_right")
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.x > 1:
			animated_sprite_2d.animation = "jump"
		elif velocity.x < -1:
			animated_sprite_2d.animation = "jumpl"
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
