class_name VampForAttackEffect extends Effect

var power: float = 0
var count: int = 0

func _init(_instigator: Node, _power: float, _count=5):
	super(_instigator)
	power = _power
	count = _count

func update_on_attack(_damage: float, _instigator: Node = null) -> float:
	if owner.health:
		print("=> Vamp Heal ", _damage * power)
		owner.health.add(_damage * power)
	return _damage
