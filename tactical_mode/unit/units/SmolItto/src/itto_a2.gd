class_name IttoA2 extends DirectedAbility

@export var power: float = 100


func apply():
	for node in selected:
		await owner.play("ability")
		var unit = node as Unit
		if unit.health:
			unit.health.add(power)
			get_map().write_info(
				"=> " + owner.unit_name + " восстанавливает  " + str(int(power)) + " хп у " + unit.unit_name
			)
	owner.play("idle")
	return true
	
func unselect(_node):
	return
