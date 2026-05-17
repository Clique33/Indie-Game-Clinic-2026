extends Component
class_name FlameSpawnerComponent


@export var parent_node : Node
@export var spawn_at_position : Marker2D


var flame_scene : PackedScene = preload("uid://bn8cattr3rwi")


func spawn_flame(light_radius_scale : float = 1, color : Color = Color.hex(0xffdaa3), hidden : bool = true) -> Flame:
	if not spawn_at_position or not parent_node:
		push_warning("Cannot Spawn. Either 'Parent Node' or 'Spawn At Position' not set.")
		return null
	var new_flame : Flame = flame_scene.instantiate()
	if hidden:
		new_flame.call_deferred("hide_flame")
	new_flame.set_deferred("color",color)
	new_flame.set_deferred("light_radius_scale",light_radius_scale)
	parent_node.call_deferred("add_child",new_flame)
	new_flame.set_deferred("position",spawn_at_position.position)
	return new_flame
