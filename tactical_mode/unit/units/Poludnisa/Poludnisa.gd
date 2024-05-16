class_name PoludnisaUnit extends Unit


func ai(map: TacticalMap):
	var a0: ApplyEffectAbility = get_abilities()[0]
	if a0.can_use():
		var rng = RandomNumberGenerator.new()
		map._prepare_ability(a0)
		
		var pos_targets = []
		for t in a0.selectable_tab:
			var has = false
			for e in t.get_effects():
				if (e as Effect).effect_name != a0.effect.effect_name:
					continue
				if not e.instigator or e.instigator.unit_name != unit_name:
					continue
				has = true
				break
			if not has:
				pos_targets.append(t)
		if pos_targets:
			a0.select(pos_targets[rng.randi_range(0, len(pos_targets) - 1)])
		else:
			a0.select(a0.selectable_tab[rng.randi_range(0, len(a0.selectable_tab) - 1)])
		await map._apply_ability()
	else:
		await ai_random_move(map)


func get_move_distance() -> int:
	return min(1, super())
