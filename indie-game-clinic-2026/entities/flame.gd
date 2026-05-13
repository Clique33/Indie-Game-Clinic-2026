extends CharacterBody2D
class_name Flame

@export var speed : float = 200
@export var shoot_left : bool = true
@export var intensity : float = 3:
	set(value):
		intensity = value
		if flame_light:
			flame_light.energy = value
@export var light_radius_scale : float = 1:
	set(value):
		light_radius_scale = value
		if flame_light:
			flame_light.texture_scale = value
@export var color : Color = Color.hex(0xffdaa3):
	set(value):
		color = value
		if flame_light:
			flame_light.color = value


var is_attached : bool = false
var _was_shot : bool = false


@onready var flame_light: PointLight2D = $FlameLight
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var flame_sprite: AnimatedSprite2D = $FlameSprite


func _ready() -> void:
	flame_light.energy = intensity
	if get_parent() is Player:
		is_attached = true
		flame_sprite.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if not _was_shot:
		return
	if get_last_slide_collision():
		queue_free()
	if shoot_left:
		velocity = Vector2.LEFT * speed
	else:
		velocity = Vector2.RIGHT * speed
	move_and_slide()


func hide_flame() -> void:
	if flame_sprite:
		flame_sprite.visible = false


func show_flame() -> void:
	if flame_sprite:
		flame_sprite.visible = true


func shoot() -> void:
	if _was_shot:
		return
	_was_shot = true
	visible = true
	collision_shape.disabled = false
	flame_sprite.visible = true
	set_deferred("is_attached",false)
	call_deferred("reparent",get_tree().root)
