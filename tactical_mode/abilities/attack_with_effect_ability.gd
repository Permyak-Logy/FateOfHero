class_name AttackWithEffectAbility extends AttackAbility

@export var effect: Effect

func apply():
	for i in range(len(selected)):
		await owner.play("ability")
		var unit = selected[i] as Unit
		var e = effect.duplicate(true)
		e.instigator = owner
		unit.add_effect(e)
		await owner.play("idle")
	return true
