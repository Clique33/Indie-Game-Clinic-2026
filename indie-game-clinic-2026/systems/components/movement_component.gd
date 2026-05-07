extends Component


@export var speed : float = 80.0


@onready var entity : CharacterBody2D = parent as CharacterBody2D 


func _physics_process(_delta: float) -> void:
	
	var direction : Vector2 = Input.get_vector("walk_left", "walk_right","walk_up","walk_down")
	entity.velocity = direction * speed

	entity.move_and_slide()
