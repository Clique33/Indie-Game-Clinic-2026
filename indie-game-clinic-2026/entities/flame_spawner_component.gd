extends Component
class_name FlameSpawnerComponent

@export var parent_node : Node
@export var spawn_at_position : Marker2D


var flame_scene : PackedScene = preload("uid://bn8cattr3rwi")


func spawn_flame() -> Flame:
	if not spawn_at_position or not parent_node:
		push_warning("Cannot Spawn. Either 'Parent Node' or 'Spawn At Position' not set.")
		return null
	var new_flame : Flame = flame_scene.instantiate()
	parent_node.call_deferred("add_child",new_flame)
	new_flame.set_deferred("global_position",spawn_at_position.global_position)
	return new_flame
