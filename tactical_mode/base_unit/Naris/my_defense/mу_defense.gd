class_name MyDefenseAbility extends Ability

@export var power: float = 25

func _init():
	acts = 1
	final_act = true
	targets = 1
	
	name = "Моя оборона"

func apply():
	var unit = selected[0] as Unit
	
	await owner.play("premydefense")
	print(name, " for ", unit)
	unit.add_effect(ShieldEffect.new(owner, power))
	await owner.play("postmydefense")
	
	return true

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	return get_map().is_player(owner) == get_map().is_player(node)
