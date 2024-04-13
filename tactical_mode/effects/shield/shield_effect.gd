class_name ShieldEffect extends Effect

var power: float = 0

func _init(_instigator: Node, _power: float):
	super(_instigator)
	power = _power
	
func update_on_damage(_damage: float, _instigator: Node = null) -> float:
	var diff = min(power, _damage)
	_damage -= diff
	power -= diff
	if power <= 0:
		finished.emit(self)
	return _damage
