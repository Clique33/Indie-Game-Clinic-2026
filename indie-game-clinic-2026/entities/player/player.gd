extends CharacterBody2D
class_name Player

@export var speed : float = 80.0


func _physics_process(delta: float) -> void:
	
	var direction : Vector2 = Input.get_vector("walk_left", "walk_right","walk_up","walk_down")
	velocity = direction * speed

	move_and_slide()
