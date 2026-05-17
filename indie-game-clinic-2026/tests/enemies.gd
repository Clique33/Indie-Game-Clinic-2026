extends Node2D


@export var player : Player


func _ready() -> void:
	if player:
		connect_lamps_to_enemies()


func connect_lamps_to_enemies() -> void:
	for enemy : Enemy in get_children():
		player.player_is_vulnerable.connect(enemy.player_is_vulnerable)
		player.player_is_dimming.connect(enemy.stalk_player)
