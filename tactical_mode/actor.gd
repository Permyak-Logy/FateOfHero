class_name Actor extends Node2D

func get_cell() -> Vector2i:
	return get_map().to_map(global_position)

func get_occupied_cells() -> Array[Vector2i]:
	return [get_cell()]

func get_map() -> TacticalMap:
	return get_parent() as TacticalMap
