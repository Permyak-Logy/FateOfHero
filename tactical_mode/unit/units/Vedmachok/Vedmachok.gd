class_name Vedmachok extends Unit


func ai(map: TacticalMap):
	var a1: SpawnAbility = get_abilities()[1]
	
	if a1.can_use():
		var rng = RandomNumberGenerator.new()
		var t = 0
		var cell = Vector2i(-1, -1)
		while not a1.can_select_cell(cell) and t < 10:
			cell = get_cell()
			t += 1
			cell = get_cell() + Vector2i(
				rng.randi_range(-a1.range_apply, a1.range_apply),
				rng.randi_range(-a1.range_apply, a1.range_apply)
			)
		if a1.can_select_cell(cell):
			map._prepare_ability(a1)
			a1.select_cell(cell)
			map._apply_ability()
		else:
			ai_random_move(map)
	else:
		ai_random_move(map)
