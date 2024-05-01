class_name ImmortalityForAttack extends Effect

@export var count: float = 0

func update_on_damage(_damage: float, _instigator: Node = null) -> float:
	if count == 0:
		return _damage
	count -= 1
	if count <= 0:
		finished.emit(self)
	return 0

func is_active():
	return count > 0
