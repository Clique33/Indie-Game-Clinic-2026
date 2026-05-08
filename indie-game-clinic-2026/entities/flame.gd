extends CharacterBody2D
class_name Flame

@export var speed : float = 100
@export var shoot_left : bool = true
@export var intensity : float = 1:
	set(value):
		intensity = value
		if flame_light:
			flame_light.energy = value


var is_attached : bool = false
var _was_shot : bool = false


@onready var flame_light: PointLight2D = $FlameLight


func _ready() -> void:
	flame_light.energy = intensity
	if get_parent() is Player:
		is_attached = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not _was_shot:
		return
	if shoot_left:
		velocity = Vector2.LEFT * speed
	else:
		velocity = Vector2.RIGHT * speed
	move_and_slide()


func shoot() -> void:
	if _was_shot:
		return
	_was_shot = true
	call_deferred("reparent",get_tree().root)
	set_deferred("is_attached",false)
