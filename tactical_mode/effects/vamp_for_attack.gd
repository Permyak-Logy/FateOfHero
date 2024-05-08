class_name VampForAttackEffect extends Effect

@export var power: float = 0.2
@export var count: int = 5

func update_on_attack(_damage: float, _instigator: Node = null) -> float:
	if owner.health:
		var diff = -owner.health.cur()
		owner.health.add(_damage * power)
		diff += owner.health.cur()
		get_map().write_info(
			"=> " + effect_name + " " + str(int(diff)) + " (" + owner.unit_name + ")"
		)
	return _damage
