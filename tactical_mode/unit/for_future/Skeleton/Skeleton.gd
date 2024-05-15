class_name Skeleton extends Unit


func ai(map: TacticalMap):
	var a0 = get_abilities()[0]
	
	if a0.can_use():
		map._prepare_ability(a0)
		map._apply_ability(a0)
	else:
		ai_random_move(map)
