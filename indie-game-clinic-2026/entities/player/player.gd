extends CharacterBody2D
class_name Player


signal player_is_vulnerable
signal player_is_dimming


@export var time_to_fully_dim : float = 15
@export var time_till_get_attacked : float = 1.5


var flame_sprite: Flame:
	set(value):
		flame_sprite = value
		if not flame_sprite:
			vulnerable_light.visible = true
			get_tree().create_timer(time_till_get_attacked).timeout.connect(_await_to_be_vulnerable)
		else:
			vulnerable_light.visible = false
			_is_vulnerable = false
var light_sources_in_range : Array[Lamp] = []
var _is_dead : bool = false
var _is_vulnerable : bool = false


@onready var vulnerable_light: PointLight2D = $VulnerableLight
@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var movement_component: MovementComponent = $MovementComponent
@onready var flame_spawner_component: FlameSpawnerComponent = $FlameSpawnerComponent
@onready var can_ignite_label: Label = $Debug/VBoxContainer/CanIgniteLabel
@onready var is_light_source_in_range_label: Label = $Debug/VBoxContainer/IsLightSourceInRangeLabel
@onready var footsteps_player: AudioStreamPlayer2D = $SfxPlayers/FootstepsPlayer
@onready var jump_player: AudioStreamPlayer2D = $SfxPlayers/JumpPlayer
@onready var land_player: AudioStreamPlayer2D = $SfxPlayers/LandPlayer
@onready var light_dimmer: LightDimmer = $LightDimmer


func _ready() -> void:
	if has_node("FlameSprite"):
		flame_sprite = get_node("FlameSprite")
	else:
		flame_sprite = flame_spawner_component.spawn_flame(1.5,Color.WHITE)
		if flame_sprite:
			light_dimmer.start(time_to_fully_dim)


func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	if _is_vulnerable:
		player_is_vulnerable.emit()
	handle_light_lamps()
	handle_shoot_flame()
	handle_spawn_flame()


func died():
	_is_dead = true
	movement_component.enabled = false
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()

func handle_light_lamps() -> void:
	if light_sources_in_range.is_empty():
		return
	
	if Input.is_action_just_released("turn_on"):
		for lamp in light_sources_in_range:
			lamp.turn_on()


func handle_shoot_flame() -> void:
	if not flame_sprite:
		return
	
	if Input.is_action_just_released("shoot_flame"):
		flame_sprite.shoot_left = movement_component.get_is_facing_left()
		flame_sprite.shoot()
		flame_sprite = null


func handle_spawn_flame() -> void:
	if not can_ignite() or light_sources_in_range.is_empty():
		return
	if Input.is_action_just_released("turn_on"):
		if not are_there_any_light_sources_lit():
			return
		flame_sprite = flame_spawner_component.spawn_flame(1.5)
		if flame_sprite:
			light_dimmer.start(time_to_fully_dim)


func are_there_any_light_sources_lit() -> bool:
	for light_source in light_sources_in_range:
		if light_source.is_turned_on:
			return true
	return false


func can_ignite() -> bool:
	return not flame_sprite


func _on_can_be_iluminated_area_area_entered(area: Area2D) -> void:
	if area.name == "IluminableArea":
		light_sources_in_range.append(area.get_parent().lamp)
	is_light_source_in_range_label.text = "light sources: " + str(light_sources_in_range)


func _on_can_be_iluminated_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is LampAreasManager:
		light_sources_in_range.erase((area.get_parent() as LampAreasManager).lamp)
	is_light_source_in_range_label.text = "light sources: " + str(light_sources_in_range) 


func _on_movement_component_changed_facing(left: bool) -> void:
	if left:
		base_sprite.flip_h = true
	else:
		base_sprite.flip_h = false


func _on_landed() -> void:
	land_player.play(0.08)


func _on_movement_component_changed_state(_name: MovementComponent.PossibleStates) -> void:
	match _name:
		MovementComponent.PossibleStates.IDLE:
			base_sprite.play("idle")
		MovementComponent.PossibleStates.WALKING:
			base_sprite.play("walk")
		MovementComponent.PossibleStates.GOING_UP:
			base_sprite.play("jump")
			jump_player.play(0.3)
		MovementComponent.PossibleStates.GOING_DOWN:
			base_sprite.play("fall")


func _on_base_sprite_frame_changed() -> void:
	match base_sprite.animation:
		"walk":
			match base_sprite.frame:
				2,7:
					footsteps_player.play()


func _on_light_dimmer_timeout() -> void:
	flame_sprite.queue_free()
	flame_sprite = null


func _on_light_dimmer_percentage_passed(current_percentage: float) -> void:
	if not flame_sprite:
		return
	if current_percentage > 0.3:
		player_is_dimming.emit()
	flame_sprite.light_radius_scale *= (1-light_dimmer.percentage_to_signal)


func _await_to_be_vulnerable() -> void:
	_is_vulnerable = true
