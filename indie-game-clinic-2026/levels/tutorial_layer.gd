extends CanvasLayer

@onready var tecla_enter: TextureRect = $Control/TeclaEnter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func alternate_enter() -> void:
	(tecla_enter.texture as AtlasTexture).region = Rect2(64,0,64,64)
