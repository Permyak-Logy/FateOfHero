class_name LugozavrUnit extends Unit

var target: Unit = null

func ai(map: TacticalMap):
	map.acts = 0
	var rng = RandomNumberGenerator.new()
	var path = []
	var cell = Vector2i(-1, -1)
	while not map.can_move_to(cell):
		cell = map.to_map(global_position) + Vector2i(rng.randi_range(-3, 3), rng.randi_range(-3, 3))
	
	map.select_path_to(cell)
	map._move_active_unit()
