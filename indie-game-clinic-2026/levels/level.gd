extends Node2D
class_name Level


signal player_lost
signal player_won


@export var player : Player:
	set(value):
		player = value
		if not player:
			return
		if player_initial_position:
			player.position = player_initial_position.position
		if enemies:
			for enemy : Enemy in enemies.get_children():
				enemy.player = player


@onready var enemies: Node2D = $Enemies
@onready var player_initial_position: Marker2D = $PlayerInitialPosition
@onready var left_limit: Marker2D = $LeftLimit
@onready var right_limit: Marker2D = $RightLimit
@onready var bottom_limit: Marker2D = $BottomLimit
@onready var win_area: Area2D = $WinArea


func _ready() -> void:
	player = player			# Calling set_player for the first time


func set_camera_limits(camera : Camera2D) -> void:
	camera.limit_bottom = get_limit('bottom')
	camera.limit_top = get_limit('top')
	camera.limit_left = get_limit('left')
	camera.limit_right = get_limit('right')


func get_limit(which: String) -> float:
	match which.to_upper():
		"BOTTOM":
			return bottom_limit.global_position.y
		"RIGHT":
			return right_limit.global_position.x
		"LEFT":
			return left_limit.global_position.x
		"TOP":
			return win_area.global_position.y
	push_error("get_limit works only for top, bottom, left or right")
	return INF


func _on_lose_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_lost.emit()


func _on_win_area_body_entered(body: Node2D) -> void:
	if body is Player:
		await get_tree().create_timer(0.5).timeout
		player_won.emit()
