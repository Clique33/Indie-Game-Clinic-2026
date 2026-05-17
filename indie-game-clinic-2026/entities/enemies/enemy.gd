extends CharacterBody2D
class_name Enemy

const LIGHTING_X_ORIGINAL : float = 0
const LIGHTING_X_FLIPPED : float = 15
const MOUTH_X_ORIGINAL : float = 2
const MOUTH_X_FLIPPED : float = 4
const HITBOX_X_ORIGINAL : float = -2
const HITBOX_X_FLIPPED : float = 3


signal killed_player


@export var player : Player
@export_group("Idle","idle_")
@export var idle_min_distance_to_player : float = 200
@export var idle_speed_back_to : float = 200
@export_group("Stalk","stalk_")
@export var stalk_speed : float = 200
@export var stalk_max_distance_to_player : float = 250
@export var stalk_min_distance_to_player : float = 200
@export var stalk_max_distance : float = 400
@export_group("Other Speeds","speed_")
@export var speed_attack : float = 200
@export var speed_run_away : float = 200


var initial_position : Vector2
var direction_vector : Vector2
var current_speed : float
var distance_to_player : float
var _is_dead : bool = false


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var lighting: Node2D = $Sprite/Lighting
@onready var mouth_occluder: LightOccluder2D = $Sprite/Lighting/MouthOccluder
@onready var hit_box: Area2D = $HitBox
@onready var state_machine_player: StateMachinePlayer = $StateMachineManager/StateMachinePlayer
@onready var right_eye: PointLight2D = $Sprite/Lighting/RightEyeOccluder/RightEye
@onready var left_eye: PointLight2D = $Sprite/Lighting/LeftEyeOccluder/LeftEye


func _ready() -> void:
	initial_position = global_position
	direction_vector = Vector2.ZERO
	current_speed = idle_speed_back_to


func _physics_process(_delta: float) -> void:
	if _is_dead:
		return
	if Input.is_action_just_released("ui_cancel"):
		die()
	if player:
		distance_to_player = abs(global_position.distance_to(player.global_position))
		transition_state_machine()
		look_to(is_right())
	velocity = direction_vector*current_speed
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_released("turn_on"):
		look_to(true)


func die() -> void:
	_is_dead = true
	sprite.material = preload("uid://dsk1ktabdq4vd")
	var tween : Tween = create_tween()
	var death_animation_time : float = 1.5
	tween.tween_property(
				sprite.material, 
				"shader_parameter/DissolverValue", 
				0, 
				death_animation_time)
	tween.parallel().tween_property(right_eye,"energy",0,death_animation_time/2)
	tween.parallel().tween_property(left_eye,"energy",0,death_animation_time/2)
	await tween.finished
	queue_free()



func is_right() -> bool:
	return 	abs(
				rad_to_deg(
					global_position.angle_to_point(
						player.global_position)
					)
				) < 90


func player_is_close() -> bool:
	return distance_to_player < idle_min_distance_to_player


func run_away_from(danger : Lamp) -> void:
	state_machine_player.set_trigger("light_within_range")
	direction_vector = danger.global_position.direction_to(global_position)
	current_speed = speed_run_away


func stop_running_away_from(_danger : Lamp) -> void:
	state_machine_player.set_trigger("light_out_of_range")


func attack_player() -> void:
	direction_vector = global_position.direction_to(player.global_position)
	current_speed = speed_attack


func stalk_player() -> void:
	if distance_to_player > stalk_max_distance:
		return
	if distance_to_player < stalk_min_distance_to_player:
		current_speed = -stalk_speed
	elif distance_to_player > stalk_max_distance_to_player:
		current_speed = stalk_speed
	else:
		current_speed = 0
	direction_vector = global_position.direction_to(player.global_position)


func idle_away_from_player() -> void:
	if player_is_close():
		direction_vector = player.global_position.direction_to(global_position)
		current_speed = idle_speed_back_to
	elif abs(global_position.distance_to(initial_position)) < 10:
		global_position = initial_position
		direction_vector = Vector2.ZERO
		state_machine_player.set_trigger("back_to_initial_pos")
	else:
		direction_vector = global_position.direction_to(initial_position)
		current_speed = idle_speed_back_to


func stop_movement() -> void:
	current_speed = 0
	direction_vector = Vector2.ZERO


func look_to(right : bool) -> void:
	if right:
		mouth_occluder.position.x = MOUTH_X_FLIPPED
		lighting.position.x = LIGHTING_X_FLIPPED
		hit_box.position.x = HITBOX_X_FLIPPED
	else:
		mouth_occluder.position.x = MOUTH_X_ORIGINAL
		lighting.position.x = LIGHTING_X_ORIGINAL
		hit_box.position.x = HITBOX_X_ORIGINAL
	sprite.flip_h = right


func transition_state_machine() -> void:
	state_machine_player.set_param("player_is_vulnerable",player._is_vulnerable)
	state_machine_player.set_param("player_is_safe",player._is_safe)
	state_machine_player.set_param("player_is_dimming",player._is_dimming)
	state_machine_player.set_param("player_is_close",player_is_close())
	print(state_machine_player.get_params())


func _on_hit_box_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	if (body as Player)._is_vulnerable:
		killed_player.emit()
		state_machine_player.set_trigger("player_is_dead")
