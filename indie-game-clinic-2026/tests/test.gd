extends Node2D


@onready var enemies: Node2D = $Enemies
@onready var player: Player = $Player
@onready var reload_timer: Timer = $ReloadTimer


func _on_player_player_died() -> void:
	reload_timer.start(1)
	

func _on_reload_timer_timeout() -> void:
	EasyTransition.transition_to_path("uid://dg6sve8kidkd3",1,EasyTransition.TransitionAnim.BLUR)
