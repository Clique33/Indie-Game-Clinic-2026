extends Node2D
class_name Level


signal player_fell


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player_fell.emit()
