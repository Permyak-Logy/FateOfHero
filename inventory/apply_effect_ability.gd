class_name ApplyEffectAbility extends DirectedAbility

@export var effect: Effect
@export var apply_on: Array[TacticalMap.relation]

func apply():
	for i in range(len(selected)):
		await owner.play("ability")
		var unit = selected[i] as Unit
		var e = effect.duplicate(true)
		e.instigator = owner
		unit.add_effect(e)
	return true

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	return get_map().get_relation(owner, unit) in apply_on
