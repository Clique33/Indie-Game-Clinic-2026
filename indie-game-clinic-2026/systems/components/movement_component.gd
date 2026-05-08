extends Component


@export var speed : float = 80.0


var _is_facing_left : bool = false


@onready var entity : CharacterBody2D = parent as CharacterBody2D 


func _physics_process(_delta: float) -> void:
	
	var direction : Vector2 = Input.get_vector("walk_left", "walk_right","walk_up","walk_down")
	entity.velocity = direction * speed
	if direction.x < 0:
		_is_facing_left = true
	if direction.x > 0:
		_is_facing_left = false
	entity.move_and_slide()


func get_is_facing_left() -> bool:
	return _is_facing_left
