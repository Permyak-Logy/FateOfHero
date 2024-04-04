extends "res://tactical_mode/base_unit/unit.gd"

class_name Skeleton

@onready var tile_map = $"../TileMap"

var current_id_path: Array = []
signal walk_finished

func play(name, args=null):
	if name == "walk":
		current_id_path = args
		await walk_finished

func _physics_process(delta):
	if current_id_path.is_empty():
		return
		
	var target_position = tile_map.map_to_local(current_id_path.front())

	global_position = global_position.move_toward(target_position, 3)
	if global_position == target_position:    
		current_id_path.pop_front()
		if not current_id_path:
			walk_finished.emit()
