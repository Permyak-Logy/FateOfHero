class_name Skeleton extends Unit


func ai(map: TacticalMap):
	var a0 = get_abilities()[0]
	
	if a0.can_use():
		map._prepare_ability(a0)
		a0.select(a0.selectable_tab[randi_range(0, len(a0.selectable_tab) - 1)])
		map._apply_ability(a0)
	else:
		var ts = map.get_units_with_relation(self, TacticalMap.relation.Enemy)
		ai_move_to(map, ts[randi_range(0, len(ts) - 1)].get_cell())
