extends CharacterBody2D
class_name Player


signal player_died


@export var time_to_fully_dim : float = 15


var flame_sprite: Flame:
	set(value):
		flame_sprite = value
		if not flame_sprite:
			vulnerable_light.visible = true
			_is_vulnerable = true
		else:
			vulnerable_light.visible = false
			_is_vulnerable = false
			_is_dimming = false
			light_dimmer.start(time_to_fully_dim)


var light_sources_in_range : Array[Lamp] = []
var _is_dead : bool = false
var _is_vulnerable : bool = false
var _is_safe : bool = false
var _is_dimming : bool = false


@onready var vulnerable_light: PointLight2D = $VulnerableLight
@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var movement_component: MovementComponent = $MovementComponent
@onready var flame_spawner_component: FlameSpawnerComponent = $FlameSpawnerComponent
@onready var state_label: Label = $Debug/VBoxContainer/StateLabel
@onready var footsteps_player: AudioStreamPlayer2D = $SfxPlayers/FootstepsPlayer
@onready var jump_player: AudioStreamPlayer2D = $SfxPlayers/JumpPlayer
@onready var land_player: AudioStreamPlayer2D = $SfxPlayers/LandPlayer
@onready var light_dimmer: LightDimmer = $LightDimmer


func _ready() -> void:
	if has_node("FlameSprite"):
		flame_sprite = get_node("FlameSprite")
	else:
		flame_sprite = flame_spawner_component.spawn_flame(2,Color.WHITE)
		if flame_sprite:
			light_dimmer.start(time_to_fully_dim)


func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	state_label.text = "State: " + movement_component.current_state
	_is_safe = are_there_any_light_sources_lit()
	handle_light_lamps()
	handle_shoot_flame()
	handle_spawn_flame()


func died():
	if _is_dead:
		return
	_is_dead = true
	movement_component.enabled = false
	z_index = 10
	base_sprite.play("die")
	
func handle_light_lamps() -> void:
	if light_sources_in_range.is_empty():
		return
	
	if Input.is_action_just_released("turn_on"):
		movement_component.start_turn_on()


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
		if not _is_safe:
			return
		flame_sprite = flame_spawner_component.spawn_flame(2)


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


func _on_can_be_iluminated_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is LampAreasManager:
		light_sources_in_range.erase((area.get_parent() as LampAreasManager).lamp)


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
		MovementComponent.PossibleStates.TURNING_ON:
			base_sprite.play("turn_on")


func _on_base_sprite_frame_changed() -> void:
	if not base_sprite:
		return 
	match base_sprite.animation:
		"walk":
			match base_sprite.frame:
				2,7:
					footsteps_player.play()
		"turn_on":
			match base_sprite.frame:
				3:
					for lamp in light_sources_in_range:
						lamp.turn_on()


func _on_base_sprite_animation_finished() -> void:
	match base_sprite.animation:
		"turn_on":
			movement_component.end_turn_on()
		"die":
			player_died.emit()


func _on_light_dimmer_timeout() -> void:
	if not flame_sprite:
		return
	flame_sprite.queue_free()
	flame_sprite = null


func _on_light_dimmer_percentage_passed(current_percentage: float) -> void:
	if not flame_sprite:
		return
	if current_percentage > 0.3:
		_is_dimming = true
	flame_sprite.light_radius_scale *= (0.9)
