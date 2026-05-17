extends Node2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func connect_lamps_to_enemies(lamps_parent : Node2D) -> void:
	for enemy in get_children():
		for lamp in lamps_parent.get_children():
			(lamp as Lamp).connect("scare_enemy",(enemy as Enemy).run_away_from)
			(lamp as Lamp).connect("enemy_is_safe_from",(enemy as Enemy).stop_running_away_from)
