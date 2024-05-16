class_name NarisA3 extends DirectedAbility

@export var effect: Effect

func apply():
	await owner.play("ability")
	for unit in selected:
		var e = effect.duplicate(true)
		e.instigator = owner
		(unit as Unit).add_effect(e)
		for u in get_map().unit_queue:
			if u[1] == unit:
				get_map().unit_queue.erase(u)
				get_map().unit_queue.insert(1, [0, unit])
				break
	owner.play("idle")
	
