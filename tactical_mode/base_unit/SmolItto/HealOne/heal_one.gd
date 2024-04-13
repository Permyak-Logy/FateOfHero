class_name HealOneAbility extends Ability

@export var power: float = 100

func _init(_power: float = power):
	super(-1)

	acts = 1
	final_act = true
	targets = 1
	power = _power
	name = "Хилл союзника"

func apply():
	var unit = selected[0] as Unit
	if unit.health:
		await owner.play("preheal")
		unit.health.add(power)
		await owner.play("postheal")
		return true
	return false

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	return get_map().is_player(owner) == get_map().is_player(node)
