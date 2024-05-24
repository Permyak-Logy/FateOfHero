class_name Vedmachok extends Unit


func ai(map: TacticalMap):
	var a0: AttackAbility = get_abilities()[0]
	var a1: SpawnAbility = get_abilities()[1]
	
	if a1.can_use():
		var rng = RandomNumberGenerator.new()
		var t = 0
		var cell = Vector2i(-1, -1)
		while not a1.can_select(cell) and t < 10:
			cell = get_cell()
			t += 1
			cell = get_cell() + Vector2i(
				rng.randi_range(-a1.range_apply, a1.range_apply),
				rng.randi_range(-a1.range_apply, a1.range_apply)
			)
		if a1.can_select(cell):
			map._prepare_ability(a1)
			a1.select(cell)
			await map._apply_ability()
			return
	var target = find_target()
	if a0.can_select(target):
		map._prepare_ability(a0)
		a0.select(target)
		await map._apply_ability()
	elif target:
		await ai_move_to(map, target.get_cell())
	else:
		await ai_random_move(map)

func find_target() -> Unit:
	var target: Unit = null
	var dist = 100000
	for unit in get_map().get_units_with_relation(self, TacticalMap.relation.Enemy):
		if unit.is_death() or not unit.visible:
			continue
		var new_dist = get_map().distance_between_cells(get_cell(), unit.get_cell())
		if new_dist > dist:
			continue
		dist = new_dist
		target = unit
	return target
