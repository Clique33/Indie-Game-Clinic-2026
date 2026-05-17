extends Node2D


@export var level : PackedScene:
	set(value):
		level = value
		if level and reload_timer:
			var current_level : Level = level.instantiate()
			current_level.player_lost.connect(_on_player_player_died)
			current_level.player_won.connect(_on_player_won)
			current_level.player = player
			reload_timer.call_deferred("add_sibling",current_level)
			current_level.call_deferred("set_camera_limits",camera)


@onready var player: Player = $Player
@onready var reload_timer: Timer = $ReloadTimer
@onready var global_light: DirectionalLight2D = $DirectionalLight2D
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var ambience_player: AudioStreamPlayer = $AmbiencePlayer
@onready var camera: Camera2D = $Player/Camera2D
@onready var mobile_controls_layer: CanvasLayer = $MobileControlsLayer


func _ready() -> void:
	canvas_modulate.visible = true
	level = level
	if Global.is_mobile:
		mobile_controls_layer.visible = true


func _on_player_player_died() -> void:
	reload_timer.start(1)
	

func _on_reload_timer_timeout() -> void:

	if has_node("MovementTutorial"):
		EasyTransition.transition_to_path("uid://dg6sve8kidkd3",1,EasyTransition.TransitionAnim.BLUR)
	else:
		EasyTransition.transition_to_path("uid://bdud5xvf3keil",1,EasyTransition.TransitionAnim.BLUR)


func _on_bonfire_bonfire_lit() -> void:
	global_light.visible = true
	create_tween().tween_property(ambience_player,"volume_db",-25,1)


func _on_player_won() -> void:
	player.movement_component.enabled = false
	if has_node("MovementTutorial"):
		EasyTransition.transition_to_path("uid://bdud5xvf3keil",1,EasyTransition.TransitionAnim.CURTAIN)
	else:
		EasyTransition.transition_to_path("uid://qmoafetgb1nd",1,EasyTransition.TransitionAnim.CURTAIN)
