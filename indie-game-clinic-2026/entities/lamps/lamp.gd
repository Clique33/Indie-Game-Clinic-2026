extends AnimatedSprite2D
class_name Lamp


signal turned_on
signal turned_off


@export var turned_on_energy : float = 1
@export var time_to_fully_dim : float = 5.0
@export var time_to_alternate : float = .2


var enemies_in_range : Array[Enemy] = []
var _elapsed_time_since_turned_on : float
var is_turned_on : bool = false:
	set(value):
		is_turned_on = value
		if is_turned_on:
			turned_on.emit()
		else:
			turned_off.emit()
var player_in_range : Player = null

@onready var flame_sprite: AnimatedSprite2D = $FlameSprite
@onready var point_light: PointLight2D = $FlameSprite/PointLight2D
@onready var light_dimmer: LightDimmer = $LightDimmer
@onready var ignite_player: AudioStreamPlayer2D = $SoundEffects/IgnitePlayer
@onready var buzzing_player: AudioStreamPlayer2D = $SoundEffects/BuzzingPlayer
@onready var areas_manager: LampAreasManager = $AreasManager


func _ready() -> void:
	play("turned_off")
	areas_manager.update_scare_area_radius(point_light.texture_scale)


func turn_on(from_player : bool = true, _time: float = time_to_alternate) -> void:
	if is_turned_on:
		return
	if from_player:
		if not player_in_range or player_in_range.can_ignite():
			return
	ignite_player.play(0.15)
	buzzing_player.play()
	
	point_light.energy = turned_on_energy
	flame_sprite.scale = Vector2.ONE
	play("turned_on"+str(randi_range(0,1)))
	is_turned_on = true
	_elapsed_time_since_turned_on = 0
	scare_enemies_in_range()
	light_dimmer.start(time_to_fully_dim)


func update_light_intensity() -> void:
	var current_step : float = light_dimmer.get_percentage_till_finished()
	point_light.energy = inverse_lerp(0.0,turned_on_energy,current_step)
	flame_sprite.scale = Vector2.ONE * inverse_lerp(0.0,1,current_step)


func turn_off(time: float = time_to_alternate) -> void:
	if not is_turned_on:
		return
	var tween : Tween = create_tween()
	tween.tween_property(point_light,"energy",0,time)
	tween.parallel().tween_property(flame_sprite,"scale",Vector2.ZERO,time)
	await tween.finished
	is_turned_on = false
	free_enemies_in_range()
	play("turned_off")


func scare_enemies_in_range() -> void:
	for enemy : Enemy in enemies_in_range:
		enemy.run_away_from(self)


func free_enemies_in_range() -> void:
	for enemy : Enemy in enemies_in_range:
		print(enemy)
		enemy.stop_running_away_from(self)


func _on_light_dimmer_finished() -> void:
	turn_off()
