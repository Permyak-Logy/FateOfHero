class_name EvilPlantUnit extends Unit

func ai(map: TacticalMap):
	var a0: EvilPlantA0 = get_abilities()[0]
	if a0.can_use():
		map._prepare_ability(a0)
		await map._apply_ability()
	else:
		await ai_pass(map)
	
func get_move_distance() -> int:
	return 0
