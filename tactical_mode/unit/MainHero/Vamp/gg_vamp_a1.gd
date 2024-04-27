class_name GGVampA1 extends DirectedAbility

@export var power: float = 0.20
@export var count_attacks: int = 5

func _init():
	super(-1)

	acts = 1
	final_act = false
	targets = 1
	name = "Упырь"

func apply():
	var unit = selected[0] as Unit
	unit.add_effect(VampForAttackEffect.new(owner, power, count_attacks))
	return true

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	return node == owner
