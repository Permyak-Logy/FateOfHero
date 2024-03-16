extends "res://tactical_mode/base_unit/unit.gd"

class_name Vendigo

@onready var tile_map = $"../TileMap"

var current_id_path: Array = []

func walk_along(way: Array):
	current_id_path = way

func _physics_process(delta):
	if current_id_path.is_empty():
		return
		
	var target_position = tile_map.map_to_local(current_id_path.front())

	global_position = global_position.move_toward(target_position, 3)
	if global_position == target_position:    
		current_id_path.pop_front()
		if not current_id_path:
			walk_finished.emit()
