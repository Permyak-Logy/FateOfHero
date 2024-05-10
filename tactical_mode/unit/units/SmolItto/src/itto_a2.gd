class_name IttoA2 extends DirectedAbility

@export var power: float = 100


func apply():
	await owner.play("prehealteam")
	for node in selected:
		var unit = node as Unit
		if unit.health:
			unit.health.add(power)
			print("=> IttoP2 heal ", power, " for ", unit.unit_name)
	await owner.play("posthealteam")
	return true
	
func unselect(_node):
	return

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	if unit.visible:
		return false
	return get_map().is_player(owner) == get_map().is_player(node)
