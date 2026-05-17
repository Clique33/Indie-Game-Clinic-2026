extends Timer
class_name LightDimmer


signal percentage_passed(current_percentage : float)


@export_range(0.01,1.0,0.01) var percentage_to_signal : float = 0.1 


var _last_percentage_hit : float = 1


func _ready() -> void:
	one_shot = true
	timeout.connect(_on_timeout)


func _process(_delta: float) -> void:
	if is_stopped():
		return
	if get_percentage_passed() >= _last_percentage_hit*percentage_to_signal:
		percentage_passed.emit(_last_percentage_hit*percentage_to_signal)
		_last_percentage_hit += 1


func get_percentage_till_finished() -> float:
	return time_left/wait_time


func get_percentage_passed() -> float:
	return 1 - (time_left/wait_time)


func _on_timeout() -> void:
	_last_percentage_hit = 1
