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
@export_category("Speeds")
@export var back_to_idle_speed : float = 200
@export var attack_speed : float = 400
@export var run_away_speed : float = 200
@export var stalk_speed : float = 200
@export var stalk_max_distance_to_player : float = 200
@export var stalk_max_distance : float = 400


var initial_position : Vector2
var direction_vector : Vector2
var current_speed : float


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var lighting: Node2D = $Sprite/Lighting
@onready var mouth_occluder: LightOccluder2D = $Sprite/Lighting/MouthOccluder
@onready var hit_box: Area2D = $HitBox
@onready var state_machine_player: StateMachinePlayer = $StateMachineManager/StateMachinePlayer


func _ready() -> void:
	initial_position = global_position
	direction_vector = Vector2.ZERO
	current_speed = back_to_idle_speed


func _physics_process(_delta: float) -> void:
	if player:
		look_to(is_right())
	velocity = direction_vector*current_speed
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_released("turn_on"):
		look_to(true)


func is_right() -> bool:
	return 	abs(
				rad_to_deg(
					global_position.angle_to_point(
						player.global_position)
					)
				) < 90


func player_is_vulnerable() -> void:
	state_machine_player.set_trigger("player_is_vulnerable")


func player_is_dimming() -> void:
	state_machine_player.set_trigger("player_is_dimming")


func run_away_from(danger : Lamp) -> void:
	state_machine_player.set_trigger("light_within_range")
	direction_vector = danger.global_position.direction_to(global_position)
	current_speed = run_away_speed


func stop_running_away_from(_danger : Lamp) -> void:
	state_machine_player.set_trigger("light_out_of_range")


func attack_player() -> void:
	direction_vector = global_position.direction_to(player.global_position)
	current_speed = attack_speed
	print("atacking")


func stalk_player() -> void:
	var distance_to_player : float = abs(global_position.distance_to(player.global_position))
	if distance_to_player > stalk_max_distance:
		return
	if distance_to_player > stalk_max_distance_to_player:
		current_speed = stalk_speed
	else:
		current_speed = 0
	direction_vector = global_position.direction_to(player.global_position)


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


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is Player:
		killed_player.emit()
		state_machine_player.set_trigger("player_is_dead")
