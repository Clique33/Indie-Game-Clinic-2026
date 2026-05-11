extends Component
class_name MovementComponent


signal changed_facing(left : bool)
signal jumped
signal landed
signal started_walking
signal stopped_walking


@export var speed : float = 100.0
@export var jump_velocity : float = -500


var _is_facing_left : bool = false
var _on_air : bool = false
var _is_walking : bool = false


@onready var entity : CharacterBody2D = parent as CharacterBody2D 


func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_jump()
	handle_walk()
	print(_on_air)
	entity.move_and_slide()


func handle_walk() -> void:
	var direction : float = Input.get_axis("walk_left", "walk_right")
	if not direction:
		entity.velocity.x = move_toward(entity.velocity.x, 0, speed)
		_is_walking = false
		stopped_walking.emit()
	else:
		if not (_is_walking or _on_air):
			_is_walking = true
			started_walking.emit()
		
		if direction < 0 and not _is_facing_left:
			_is_facing_left = not _is_facing_left
			changed_facing.emit(_is_facing_left)
		elif direction > 0 and _is_facing_left:
			_is_facing_left = not _is_facing_left
			changed_facing.emit(_is_facing_left)
		entity.velocity.x = direction * speed


func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and entity.is_on_floor():
		entity.velocity.y = jump_velocity


func handle_gravity(delta : float) -> void:
	if _on_air and entity.is_on_floor():
		_on_air = false
		landed.emit()
	if not _on_air and not entity.is_on_floor():
		_on_air = true
		jumped.emit()
		
	if not entity.is_on_floor():
		if entity.velocity.y > 0:
			delta *= 2
		entity.velocity += entity.get_gravity() * delta


func get_is_facing_left() -> bool:
	return _is_facing_left
