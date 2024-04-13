class_name HealTeamAbility extends Ability

@export var power: float = 100
 
func _init(_power: float = power):
	super(-1)
	
	acts = 1
	final_act = true
	targets = 1
	max_targets = 0
	name = "Хилл отряда"

func apply():
	await owner.play("prehealteam")
	for node in selected:
		var unit = selected[0] as Unit
		if unit.health:
			unit.health.add(power)
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
	return get_map().is_player(owner) == get_map().is_player(node)
