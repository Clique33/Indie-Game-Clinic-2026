extends Node2D


@onready var enemies: Node2D = $Enemies
@onready var lamps: Node2D = $Lamps


func _ready() -> void:
	enemies.connect_lamps_to_enemies(lamps)
