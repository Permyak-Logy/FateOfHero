class_name VampA3 extends DirectedAbility

@export var power_self: ModValue = ModValue.new()
@export var power_target: ModValue = ModValue.new()

func apply():
	await owner.play("ability")
	var unit = selected[0] as Unit
	
	
	var heal = scale * power_target.mul + power_target.add
	owner.health.sub(scale * power_self.mul + power_target.add)
	unit.health.add(heal)
	
	get_map().write_info(
		"=> " + owner.unit_name + "восстанавливает " + str(int(heal)) + " здоровья " + unit.unit_name)
	owner.play("idle")
	return true
