class_name MainHeroEffect extends Effect


func on_set_owner(old: Unit, new: Unit):
	if old:
		old.death.disconnect(on_death)
	if new:
		new.death.connect(on_death)

func on_death(unit: Unit):
	get_map().running = false
