extends Node2D
class_name LampAreasManager


@export var scare_area_base_radius : float = 128


@onready var lamp : Lamp = get_parent()
@onready var scare_collision_shape: CollisionShape2D = $ScareArea/CollisionShape2D


func _ready() -> void:
	update_scare_area_radius(1)


func _on_iluminable_area_area_entered(area: Area2D) -> void:
	if not area.get_parent():
		return
	
	if 	(area.get_parent() is Flame and 
			not (area.get_parent() as Flame).is_attached and 
				not lamp.is_turned_on):
		lamp.turn_on(false)
	
	if area.get_parent() is Player:
		if lamp.is_turned_on:
			(area.get_parent() as Player)._is_vulnerable = false
		if (area.get_parent() as Player).can_ignite:
			lamp.player_in_range = area.get_parent() as Player


func _on_iluminable_area_area_exited(area: Area2D) -> void:
	if not area.get_parent():
		return
	if area.get_parent() is Player:
		lamp.player_in_range = null


func _on_scare_area_body_entered(body: Node2D) -> void:
	if not body is Enemy:
		return
	lamp.enemies_in_range.append(body)
	if lamp.is_turned_on:
		(body as Enemy).run_away_from(lamp)


func _on_scare_area_body_exited(body: Node2D) -> void:
	if not body is Enemy:
		return
	lamp.enemies_in_range.erase(body)
	(body as Enemy).stop_running_away_from(lamp)


func update_scare_area_radius(multiplier: float) -> void:
	scare_collision_shape.shape.radius = scare_area_base_radius*multiplier
