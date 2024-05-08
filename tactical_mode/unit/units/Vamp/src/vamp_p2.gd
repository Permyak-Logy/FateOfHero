class_name VampP2 extends Effect

@export var power: float = 0.25

func update_on_attack(_damage: float, _instigator: Node = null) -> float:
	var count = 0
	for elem in owner.get_map().get_units_with_relation(owner, TacticalMap.relation.Friend):
		if elem.is_death():
			count += 1
	_damage *= (1 + power * count)
	print("=> Up damage on ", power * count, " by Влюблённый монстр")
	power = 0
	return _damage
