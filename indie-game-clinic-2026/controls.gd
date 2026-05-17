extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_left_pressed() -> void:
	Input.action_press("walk_left")


func _on_left_released() -> void:
	Input.action_release("walk_left")


func _on_right_pressed() -> void:
	Input.action_press("walk_right")


func _on_right_released() -> void:
	Input.action_release("walk_right")


func _on_jump_pressed() -> void:
	Input.action_press("jump")


func _on_jump_released() -> void:
	Input.action_release("jump")


func _on_light_pressed() -> void:
	Input.action_press("turn_on")


func _on_light_released() -> void:
	Input.action_release("turn_on")
