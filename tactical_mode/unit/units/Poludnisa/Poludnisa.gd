class_name PoludnisaUnit extends Unit


func ai(map: TacticalMap):
	var a0: ApplyEffectAbility = get_abilities()[0]
	if a0.can_use():
		var rng = RandomNumberGenerator.new()
		map._prepare_ability(a0)
		
		a0.select(a0.selectable_tab[rng.randi_range(0, len(a0.selectable_tab) - 1)])
		await map._apply_ability()
	else:
		await ai_random_move(map)


func get_move_distance() -> int:
	return max(1, super())
