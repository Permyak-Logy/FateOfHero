class_name IttoA1 extends DirectedAbility

@export var power: float = 100

func apply():
	var unit = selected[0] as Unit
	if unit.health:
		await owner.play("preheal")
		unit.health.add(power)
		await owner.play("postheal")
		print("=> IttoA1 heal", power, " for ", unit.unit_name)
		return true
	return false

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	return get_map().is_player(owner) == get_map().is_player(node)
