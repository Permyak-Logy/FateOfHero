class_name BlockStepmoveEffect extends Effect


func update_on_start_stepmove():
	get_map().acts = 0
	get_map().write_info("=> " + owner.unit_name + " не может ходить (" + effect_name + ")")
