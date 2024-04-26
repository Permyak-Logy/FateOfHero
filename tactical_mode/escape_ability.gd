class_name EscapeAbility extends Ability

func _init():
	super(-1)
	
	acts = 1
	targets = 0
	final_act = true
	name = "Побег"
	
	only_unit_owner = false

func apply():
	for unit in get_map().get_player_units():
		if not unit in selected:
			unit.kill()
		else:
			unit.health.sub(unit.health.cur() * 0.2)
	get_map().escape = true
	return true

func unselect(_node):
	return

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	if unit.get_cell()[0] != 0:
		return false
	return get_map().is_player(node)

