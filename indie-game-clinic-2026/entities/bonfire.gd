extends AnimatedSprite2D
class_name Bonfire


@onready var lamp: Lamp = $Lamp
@onready var flame_light: PointLight2D = $FlameLight


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not lamp:
		return
	
	if lamp.is_turned_on and not flame_light.visible:
		flame_light.visible = true
		play("turned_on")
	elif not lamp.is_turned_on and flame_light.visible:
		flame_light.visible = false
		play("turned_off")
