class_name GGVampA3 extends DirectedAbility

@export var power_self: float = 0.1
@export var power_target: float = 2

func apply():
	var unit = selected[0] as Unit
	
	var heal = owner.health.cur() * power_self
	owner.health.sub(heal)
	heal *= power_target
	unit.health.add(heal)
	print("=> GGVampA3 heal", heal, " for ", unit.unit_name)
	return true

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	if unit == owner:
		return false
	return get_map().is_player(owner) == get_map().is_player(node)