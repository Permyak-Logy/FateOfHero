class_name IttoA1 extends DirectedAbility

@export var power: ModValue = ModValue.new()

func apply():
	await owner.play("ability")
	var unit = selected[0] as Unit
	
	var diff = -unit.health.cur() 
	unit.health.add(scale * power.mul + power.add)
	diff += unit.health.cur()
	
	get_map().write_info("=> Востанавливает " + str(int(diff)) + " здоровья у " + unit.unit_name)
	await owner.play("idle")
	return true

func can_select(_node):
	var unit = _node as Unit
	if not super(unit):
		return false
	if not unit.health:
		return false
	if unit.health.percent() == 1:
		return false
	return true
