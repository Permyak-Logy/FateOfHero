class_name Skeleton extends Unit

var current_id_path: Array = []
signal walk_finished

func play(_name, _args=null):
	if _name == "walk":
		current_id_path = _args
		await walk_finished

func _physics_process(delta):
	if current_id_path.is_empty():
		return
		
	var target_position = $"../TileMap".map_to_local(current_id_path.front())

	global_position = global_position.move_toward(target_position, 3)
	if global_position == target_position:    
		current_id_path.pop_front()
		if not current_id_path:
			walk_finished.emit()
