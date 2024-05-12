class_name IttoA2 extends DirectedAbility

@export var power: ModValue = ModValue.new()


func apply():
	for node in selected:
		await owner.play("ability")
		var unit = node as Unit
		
		var diff = -unit.health.cur() 
		unit.health.add(scale * power.mul + power.add)
		diff += unit.health.cur()
		get_map().write_info(
			"=> " + owner.unit_name + " восстанавливает  " + str(int(diff)) + " хп у " + unit.unit_name
		)
	owner.play("idle")
	return true
	
func unselect(_node):
	pass

func tab_next():
	pass

func tab_prev():
	pass

func can_select(_node):
	var unit = _node as Unit
	if not super(unit):
		return false
	if not unit.health:
		return false
	return true
