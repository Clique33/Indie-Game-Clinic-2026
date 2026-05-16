extends Node2D
class_name LampAreasManager

signal scare_enemy(lamp : Lamp)
signal enemy_is_safe_from(lamp : Lamp)


@onready var lamp : Lamp = get_parent()


func _on_iluminable_area_area_entered(area: Area2D) -> void:
	if not area.get_parent():
		return
	
	if 	(area.get_parent() is Flame and 
			not (area.get_parent() as Flame).is_attached and 
				not lamp.is_turned_on):
		lamp.turn_on(false)
	
	if area.get_parent() is Player and (area.get_parent() as Player).can_ignite:
		lamp._player_in_range = area.get_parent() as Player


func _on_iluminable_area_area_exited(area: Area2D) -> void:
	if not area.get_parent():
		return
	if area.get_parent() is Player:
		lamp._player_in_range = null


func _on_scare_area_body_entered(body: Node2D) -> void:
	if not body is Enemy:
		return
	scare_enemy.emit(lamp)


func _on_scare_area_body_exited(body: Node2D) -> void:
	if not body is Enemy:
		return
	enemy_is_safe_from.emit(lamp)
