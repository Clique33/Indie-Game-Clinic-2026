extends CanvasLayer


var tween : Tween


@onready var player: TextureRect = $Control/VBoxContainer/Player
@onready var space_button: TextureButton = $Control/VBoxContainer/SpaceButton


func _ready() -> void:
	await get_tree().create_timer(3).timeout
	alternate_button_animation()

func _input(event: InputEvent) -> void:
	if event.is_action("jump"):
		_on_space_button_pressed()

func alternate_button_animation() -> void:
	tween = create_tween()
	tween.finished.connect(alternate_button_animation)
	if space_button.self_modulate == Color.WHITE:
		tween.tween_property(space_button,"self_modulate",Color.hex(0xffffff00),1.25)
	else:
		tween.tween_property(space_button,"self_modulate",Color.WHITE,1.25)


func _on_space_button_pressed() -> void:
	EasyTransition.transition_to_path("uid://dg6sve8kidkd3",1.5,EasyTransition.TransitionAnim.CIRCLE_CENTER_COLLAPSE)
