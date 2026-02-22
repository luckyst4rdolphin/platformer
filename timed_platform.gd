extends StaticBody2D

@export var fade_start_delay := 1.0
@export var fade_duration := 1.0
@export var respawn_delay := 5.0
@export var fade_in_duration := 1.0  

@onready var sprite: Sprite2D = $Sprite2D
@onready var solid_col: CollisionShape2D = $CollisionShape2D
@onready var area: Area2D = $Area2D

var armed := false
var active := true

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	_reset_visual()

func _on_body_entered(body: Node) -> void:
	if not active or armed:
		return
	if not (body is CharacterBody2D):
		return

	armed = true
	_run_cycle()

func _run_cycle() -> void:
	await get_tree().create_timer(fade_start_delay).timeout
	if not active:
		return

	var t := create_tween()
	t.tween_property(sprite, "modulate:a", 0.0, fade_duration)

	await get_tree().create_timer(fade_duration).timeout
	_set_enabled(false)

	await get_tree().create_timer(respawn_delay).timeout
	_respawn_with_fade()

func _set_enabled(enabled: bool) -> void:
	active = enabled
	sprite.visible = enabled
	solid_col.disabled = not enabled

func _respawn_with_fade() -> void:
	active = true
	armed = false

	sprite.visible = true
	solid_col.disabled = false

	var c := sprite.modulate
	c.a = 0.0
	sprite.modulate = c

	var t := create_tween()
	t.tween_property(sprite, "modulate:a", 1.0, fade_in_duration)

func _reset_visual() -> void:
	var c := sprite.modulate
	c.a = 1.0
	sprite.modulate = c
