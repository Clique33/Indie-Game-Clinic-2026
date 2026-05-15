extends CharacterBody2D


const LIGHTING_X_ORIGINAL : float = 0
const LIGHTING_X_FLIPPED : float = 15
const MOUTH_X_ORIGINAL : float = 2
const MOUTH_X_FLIPPED : float = 4
const HITBOX_X_ORIGINAL : float = -2
const HITBOX_X_FLIPPED : float = 3


signal killed_player


@export var player : Player


@onready var sprite: AnimatedSprite2D = $Sprite
@onready var lighting: Node2D = $Sprite/Lighting
@onready var mouth_occluder: LightOccluder2D = $Sprite/Lighting/MouthOccluder
@onready var hit_box: Area2D = $HitBox


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


func run_away_from(danger : Node2D) -> void:
	push_error("TODO")


func stop_running_away() -> void:
	push_error("TODO")


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


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.get_parent() is Flame or area.get_parent() is Lamp:
		run_away_from(area.get_parent())


func _on_hit_box_area_exited(area: Area2D) -> void:
	if area.get_parent() is Flame or area.get_parent() is Lamp:
		stop_running_away()


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is Player:
		killed_player.emit()
		print("DEAD")
