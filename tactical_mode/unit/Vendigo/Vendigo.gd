class_name Vendigo extends Unit

func ai(map: TacticalMap):
	map.acts = 0
	var rng = RandomNumberGenerator.new()
	var path = []
	while len(path) == 0:
		path = map.get_path_to_cell(
			map.to_map(global_position) + Vector2i(
				rng.randi_range(-3, 3), rng.randi_range(-3, 3)))
	await play("walk", path)

func get_occupied_cells():
	return [get_cell(), get_cell() + Vector2i(1, 0)]
