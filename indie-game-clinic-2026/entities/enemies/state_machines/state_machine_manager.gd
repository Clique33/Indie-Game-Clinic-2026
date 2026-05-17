extends Node


@export var await_to_attack_time : float = 1.5


var current_state : String


@onready var wait_to_attack_timer: Timer = $WaitToAttackTimer
@onready var state_machine_player: StateMachinePlayer = $StateMachinePlayer
@onready var parent : Enemy = get_parent()


func _on_state_machine_player_transited(_from: Variant, to: Variant) -> void:
	current_state = to
	match to:
		"Attacking":
			wait_to_attack_timer.start(await_to_attack_time)
		"PlayerDead":
			parent.player.died()


func _on_state_machine_player_updated(state: Variant, _delta: Variant) -> void:
	match state:
		
		"GoingBackToIdle":
			parent.idle_away_from_player()
	
		"Stalking":
			parent.stalk_player()
		
		"Attacking":
			if not wait_to_attack_timer.is_stopped():
				return
			parent.attack_player()
		
		"PlayerDead":
			parent.stop_movement()
