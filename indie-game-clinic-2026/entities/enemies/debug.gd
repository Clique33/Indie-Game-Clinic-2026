extends Control


@onready var state_label: Label = $VBoxContainer/State


func _on_state_machine_player_transited(_from: Variant, to: Variant) -> void:
	#print(to)
	state_label.text = "State: " + str(to)
