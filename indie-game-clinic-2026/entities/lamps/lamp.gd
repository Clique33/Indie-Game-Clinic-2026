extends Sprite2D


@export var turned_on_energy : float = 1
@export var time_to_alternate : float = 2
@export var time_to_fully_dim : float = 5.0


var _elapsed_time_since_turned_on : float
var _is_turned_on : bool = false
var _is_player_in_range : bool = false

@onready var flame_sprite: AnimatedSprite2D = $FlameSprite
@onready var point_light: PointLight2D = $FlameSprite/PointLight2D
@onready var fully_dim_timer: Timer = $FullyDimTimer
@onready var ignite_player: AudioStreamPlayer2D = $SoundEffects/IgnitePlayer
@onready var buzzing_player: AudioStreamPlayer2D = $SoundEffects/BuzzingPlayer


func _ready() -> void:
	fully_dim_timer.wait_time = time_to_fully_dim


func _physics_process(_delta: float) -> void:
	if _is_player_in_range and Input.is_action_just_released("ui_accept"):
		turn_on()
	update_light_intensity()

func turn_on(time: float = time_to_alternate) -> void:
	if _is_turned_on:
		return
	var tween : Tween = create_tween()
	tween.tween_property(point_light,"energy",turned_on_energy,time)
	tween.parallel().tween_property(flame_sprite,"scale",Vector2.ONE,time)
	ignite_player.play()
	buzzing_player.play(2.5)
	await tween.finished
	_is_turned_on = true
	_elapsed_time_since_turned_on = 0
	fully_dim_timer.start()


func update_light_intensity() -> void:
	var current_step : float = (fully_dim_timer.time_left/fully_dim_timer.wait_time)
	point_light.energy = inverse_lerp(0.0,turned_on_energy,current_step)
	flame_sprite.scale = Vector2.ONE * inverse_lerp(0.0,1,current_step)


func turn_off(time: float = time_to_alternate) -> void:
	if not _is_turned_on:
		return
	var tween : Tween = create_tween()
	tween.tween_property(point_light,"energy",0,time)
	tween.parallel().tween_property(flame_sprite,"scale",Vector2.ZERO,time)
	await tween.finished
	_is_turned_on = false


func alternate(time : float = time_to_alternate) -> void:
	if not _is_turned_on:
		turn_on(time)
	else:
		turn_off(time)


func _on_iluminable_area_area_entered(area: Area2D) -> void:
	if not area.get_parent():
		return
	print('can iluminate')
	if area.get_parent() is Player:
		_is_player_in_range = true


func _on_iluminable_area_area_exited(area: Area2D) -> void:
	if not area.get_parent():
		return
	print('cannot iluminate')
	if area.get_parent() is Player:
		_is_player_in_range = false


func _on_fully_dim_timer_timeout() -> void:
	_is_turned_on = false
	buzzing_player.stop()
