class_name VampA3 extends DirectedAbility

@export var power_self: float = 0.1
@export var power_target: float = 2

func apply():
	await owner.play("ability")
	var unit = selected[0] as Unit
	
	var heal = owner.health.cur() * power_self
	owner.health.sub(heal)
	heal *= power_target
	unit.health.add(heal)
	get_map().write_info(
		"=> " + owner.unit_name + "восстанавливает " + str(heal) + " здоровья " + unit.unit_name)
	owner.play("idle")
	return true
