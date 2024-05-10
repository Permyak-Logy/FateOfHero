class_name LugozavrUnit extends Unit

var target: Unit = null

func ai(map: TacticalMap):
	var a0: AttackAbility = get_abilities()[0]
	var a1: LugozavrA1 = get_abilities()[1]
	
	if not target or target.is_death():
		assign_target()
	if not target:
		ai_random_move(map)
	elif a1.applied == target:
		a1.subapply()
		ai_pass(map)
	elif map.distance_between_cells(target.get_cell(), get_cell()) > 1:
		ai_move_to(map, target.get_cell())
	elif a1.can_use():
		map._prepare_ability(a1)
		a1.select(target)
		map._apply_ability()
	elif a0.can_use():
		map._prepare_ability(a0)
		a0.select(target)
		map._apply_ability()

func assign_target():
	var avaliable_units: Array[Unit] = []
	for unit in get_map().get_units_with_relation(self, TacticalMap.relation.Enemy):
		if not unit.is_death() and unit.visible:
			avaliable_units.append(unit)
	if not avaliable_units:
		return
	target = avaliable_units[0]
	for unit in avaliable_units:
		if target.health.cur() > unit.health.cur():
			target = unit
