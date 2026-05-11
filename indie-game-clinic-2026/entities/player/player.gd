extends CharacterBody2D
class_name Player


var flame_sprite: Flame:
	set(value):
		flame_sprite = value
		if not value:
			_can_ignite = true
		else:
			_can_ignite = false


var _can_ignite : bool = false:
	set(value):
		_can_ignite = value
		if can_ignite_label:
			can_ignite_label.text = "can ignite? "+str(_can_ignite)


var light_sources_in_range : Array[Lamp] = []


@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var movement_component: MovementComponent = $MovementComponent
@onready var flame_spawner_component: FlameSpawnerComponent = $FlameSpawnerComponent
@onready var can_ignite_label: Label = $Debug/VBoxContainer/CanIgniteLabel
@onready var is_light_source_in_range_label: Label = $Debug/VBoxContainer/IsLightSourceInRangeLabel


func _ready() -> void:
	if has_node("FlameSprite"):
		flame_sprite = get_node("FlameSprite")
	else:
		flame_sprite = flame_spawner_component.spawn_flame()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("enter"):
		get_tree().reload_current_scene()
	handle_light_lamps()
	handle_shoot_flame()
	handle_spawn_flame()


func handle_light_lamps() -> void:
	if light_sources_in_range.is_empty():
		return
	
	if Input.is_action_just_released("ui_accept"):
		for lamp in light_sources_in_range:
			lamp.turn_on()


func handle_shoot_flame() -> void:
	if not flame_sprite:
		return
	
	if Input.is_action_just_released("shoot_flame"):
		flame_sprite.shoot_left = movement_component.get_is_facing_left()
		flame_sprite.shoot()
		flame_sprite = null
		_can_ignite = true


func handle_spawn_flame() -> void:
	if not _can_ignite or light_sources_in_range.is_empty():
		return
	if Input.is_action_just_released("ui_accept"):
		if not are_there_any_light_sources_lit():
			return
		flame_sprite = flame_spawner_component.spawn_flame()
		_can_ignite = false


func are_there_any_light_sources_lit() -> bool:
	for light_source in light_sources_in_range:
		if light_source.is_turned_on:
			return true
	return false

func _on_can_be_iluminated_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Lamp:
		light_sources_in_range.append(area.get_parent())
	is_light_source_in_range_label.text = "light sources: " + str(light_sources_in_range)


func _on_can_be_iluminated_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is Lamp:
		light_sources_in_range.erase(area.get_parent())
	is_light_source_in_range_label.text = "light sources: " + str(light_sources_in_range) 


func _on_movement_component_changed_facing(left: bool) -> void:
	if left:
		base_sprite.flip_h = true
	else:
		base_sprite.flip_h = false


func _on_jumped() -> void:
	base_sprite.play("jump")


func _on_landed() -> void:
	base_sprite.play("land")


func _on_started_walking() -> void:
	base_sprite.play("walk")


func _on_stopped_walking() -> void:
	if base_sprite.animation == "walk":
		base_sprite.stop()
