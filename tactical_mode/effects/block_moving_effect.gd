class_name BlockMovingEffect extends Effect


func update_on_move():
	get_map().acts = 0
	get_map().write_info("=> " + owner.unit_name + " не может ходить (" + effect_name + ")")
