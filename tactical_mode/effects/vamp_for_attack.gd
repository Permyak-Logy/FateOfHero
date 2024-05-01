class_name VampForAttackEffect extends Effect

@export var power: float = 0.2
@export var count: int = 5

func update_on_attack(_damage: float, _instigator: Node = null) -> float:
	if owner.health:
		print("=> Vamp Heal ", _damage * power)
		owner.health.add(_damage * power)
	return _damage
