class_name BlackHoleUnit extends Unit


func get_occupied_cells():
	return []

func get_move_distance():
	await super()
	return 0
