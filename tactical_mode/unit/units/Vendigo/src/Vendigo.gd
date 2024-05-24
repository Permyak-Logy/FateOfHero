class_name Vendigo extends Unit

func ai(map: TacticalMap):
	ai_random_move(map)

func get_occupied_cells():
	return [get_cell(), get_cell() + Vector2i(1, 0)]
