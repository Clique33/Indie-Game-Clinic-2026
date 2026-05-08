extends CharacterBody2D
class_name Player


@onready var flame_sprite: Flame = $FlameSprite
@onready var movement_component: MovementComponent = $MovementComponent


func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("shoot_flame"):
		flame_sprite.shoot_left = movement_component.get_is_facing_left()
		flame_sprite.shoot()
