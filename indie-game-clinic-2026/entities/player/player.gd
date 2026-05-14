extends CharacterBody2D
class_name Player


var flame_sprite: Flame:
	set(value):
		flame_sprite = value
		if not value:
			can_ignite = true
		else:
			can_ignite = false


var can_ignite : bool = false:
	set(value):
		can_ignite = value
		if can_ignite_label:
			can_ignite_label.text = "can ignite? "+str(can_ignite)


var light_sources_in_range : Array[Lamp] = []


@onready var base_sprite: AnimatedSprite2D = $BaseSprite
@onready var movement_component: MovementComponent = $MovementComponent
@onready var flame_spawner_component: FlameSpawnerComponent = $FlameSpawnerComponent
@onready var can_ignite_label: Label = $Debug/VBoxContainer/CanIgniteLabel
@onready var is_light_source_in_range_label: Label = $Debug/VBoxContainer/IsLightSourceInRangeLabel
@onready var footsteps_player: AudioStreamPlayer2D = $SfxPlayers/FootstepsPlayer
@onready var jump_player: AudioStreamPlayer2D = $SfxPlayers/JumpPlayer
@onready var land_player: AudioStreamPlayer2D = $SfxPlayers/LandPlayer


func _ready() -> void:
	if has_node("FlameSprite"):
		flame_sprite = get_node("FlameSprite")
	else:
		flame_sprite = flame_spawner_component.spawn_flame(Color.WHITE)


func _physics_process(_delta: float) -> void:
	handle_light_lamps()
	handle_shoot_flame()
	handle_spawn_flame()


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
		can_ignite = true


func handle_spawn_flame() -> void:
	if not can_ignite or light_sources_in_range.is_empty():
		return
	if Input.is_action_just_released("turn_on"):
		if not are_there_any_light_sources_lit():
			return
		flame_sprite = flame_spawner_component.spawn_flame()
		can_ignite = false


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
