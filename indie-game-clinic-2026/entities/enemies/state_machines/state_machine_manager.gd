extends Node


@export var await_to_attack_time : float = 1.5


var current_state : String
var _has_laughed : bool = false


@onready var wait_to_attack_timer: Timer = $WaitToAttackTimer
@onready var state_machine_player: StateMachinePlayer = $StateMachinePlayer
@onready var parent : Enemy = get_parent()


func _on_state_machine_player_transited(from: Variant, to: Variant) -> void:
	current_state = to
	if from != "Attaking" and to == "Stalking":
		parent.laugh_player.pitch_scale = randf_range(1.8,2.1)
		parent.laugh_player.play()
	
	match from:
		"Attacking":
			_has_laughed = false
	
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
			if _has_laughed:
				return
			_has_laughed = true
			parent.attack_audio_player.pitch_scale = randf_range(1.3,1.9)
			parent.attack_audio_player.play()
		
		"PlayerDead":
			parent.stop_movement()
