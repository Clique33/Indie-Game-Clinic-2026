extends CharacterBody2D


const LIGHTING_X_ORIGINAL : float = 0
const LIGHTING_X_FLIPPED : float = 15
const MOUTH_X_ORIGINAL : float = 2
const MOUTH_X_FLIPPED : float = 4


@export var player : Player


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var lighting: Node2D = $Sprite/Lighting
@onready var mouth_occluder: LightOccluder2D = $Sprite/Lighting/MouthOccluder


func _physics_process(delta: float) -> void:
	if player:
		look_to(is_right())


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


func look_to(right : bool) -> void:
	if right:
		mouth_occluder.position.x = MOUTH_X_FLIPPED
		lighting.position.x = LIGHTING_X_FLIPPED
	else:
		mouth_occluder.position.x = MOUTH_X_ORIGINAL
		lighting.position.x = LIGHTING_X_ORIGINAL
	sprite.flip_h = right
