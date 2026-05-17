extends Node


var current_state : String


@onready var state_machine_player: StateMachinePlayer = $StateMachinePlayer
@onready var parent : Enemy = get_parent()


func _on_state_machine_player_transited(_from: Variant, to: Variant) -> void:
	current_state = to
	match to:
		"GoingBackToIdle":
			parent.direction_vector = parent.global_position.direction_to(parent.initial_position)
			parent.current_speed = parent.back_to_idle_speed


func _on_state_machine_player_updated(state: Variant, _delta: Variant) -> void:
	match state:
		"GoingBackToIdle":
			if abs(parent.global_position.distance_to(parent.initial_position)) < 10:
				parent.global_position = parent.initial_position
				parent.direction_vector = Vector2.ZERO
				state_machine_player.set_trigger("back_to_initial_pos")
			
