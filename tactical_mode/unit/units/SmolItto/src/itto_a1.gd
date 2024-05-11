class_name IttoA1 extends DirectedAbility

@export var power: float = 100

func apply():
	await owner.play("ability")
	var unit = selected[0] as Unit
	
	var diff = -unit.health.cur() 
	unit.health.add(power)
	diff += unit.health.cur()
	get_map().write_info("=> Востанавливает " + str(diff) + " здоровья у " + unit.unit_name)
	owner.play("idle")
	return true

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	if not unit.visible:
		return false
	return get_map().is_player(owner) == get_map().is_player(node)
