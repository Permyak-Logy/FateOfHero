class_name LugozavrUnit extends Unit

var target: Unit = null

func ai(map: TacticalMap):
	var a0: AttackAbility = get_abilities()[0]
	var a1: LugozavrA1 = get_abilities()[1]
	
	if not target or target.is_death():
		assign_target()
	
	if not target:
		ai_random_move(map)
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
		if not unit.is_death():
			avaliable_units.append(unit)
		if not target:
			return
