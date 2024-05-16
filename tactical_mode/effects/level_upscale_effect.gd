class_name LevelUpscaleEffect extends Effect


func on_set_owner(old, new):
	if new and new.expirience:
		var lvl = new.expirience.level
		var health_mod = Mod.new()
		var defence_mod = Mod.new()
		var damage_mod = Mod.new()
		
		health_mod.type = Mod.Type.Health
		health_mod.value.mul = exp((lvl - 1.)/15) - 1
		
		defence_mod.type = Mod.Type.Defence
		defence_mod.value.mul = exp((lvl - 1.) / 15) - 1
		
		damage_mod.type = Mod.Type.Damage
		damage_mod.value.mul = exp((lvl - 1.) / 15) - 1
		print(new, " ", health_mod.value.mul, " ", defence_mod.value.mul, " ", damage_mod.value.mul)
		mods = [health_mod, defence_mod, damage_mod]
		updated_mods.emit()
