extends Node2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func connect_lamps_to_enemies(lamps_parent : Node2D) -> void:
	for enemy in get_children():
		for lamp in lamps_parent.get_children():
			pass
