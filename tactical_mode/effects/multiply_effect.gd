class_name ReplicateEffect extends Effect

@export var to_replicate_effect: Effect
@export var apply_to: Array[TacticalMap.relation] = [TacticalMap.relation.Friend]

func on_set_owner(old, new):
	for k in apply_to:
		for unit in (new as Unit).get_map().get_units_with_relation(owner, k):
			var e = to_replicate_effect.duplicate(true)
			e.instigator = owner
			unit.add_effect(e)
	await finished.emit()
