class_name IttoA1 extends DirectedAbility

@export var power: float = 100

func apply():
	var unit = selected[0] as Unit
	
	if unit.health:
		var diff = -unit.health.cur() 
		unit.health.add(power)
		diff += unit.health.cur()
		get_map().write_info("=> Востанавливает " + str(diff) + " здоровья у " + unit.unit_name)
		return true
	return false

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	return get_map().is_player(owner) == get_map().is_player(node)
