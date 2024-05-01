class_name ShieldEffect extends Effect

@export var power: float = 0

func update_on_damage(_damage: float, _instigator: Node = null) -> float:
	var diff = min(power, _damage)
	_damage -= diff
	power -= diff
	if power <= 0:
		finished.emit(self)
	return _damage

func is_active():
	return power > 0