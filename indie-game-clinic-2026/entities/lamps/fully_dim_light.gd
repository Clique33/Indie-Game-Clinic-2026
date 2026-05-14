extends Timer
class_name LightDimmer


func get_percentage_till_finished() -> float:
	return time_left/wait_time
