class_name ApplyEffectAbility extends DirectedAbility

@export var effect: Effect

func apply():
	await owner.play("ability")
	var unit = selected[0] as Unit
	var e = effect.duplicate(true)
	e.instigator = owner
	unit.add_effect(e)
	owner.play("idle")
