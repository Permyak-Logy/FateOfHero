class_name GGVampP1 extends Effect

var power_delta: float = 0.1
var power_max: float = 0.5
var power: float = 0

func set_owner(_owner):
	if owner:
		(owner.health as StatComponent).change.disconnect(on_change_health)
	super(_owner)
	_owner.health.change.connect(on_change_health)

func on_change_health(comp: StatComponent, old: float, new: float):
	if new > old:
		power = min(power_max, power + power_delta)
		print("=> Падший ангел ", owner, " -> ", power)

func update_on_attack(_damage: float, _instigator: Node = null) -> float:
	_damage *= (1 + power)
	print("=> Up damage on ", power, " by Бадший ангел")
	power = 0
	return _damage
