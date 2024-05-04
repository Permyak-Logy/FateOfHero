class_name GGVampP1 extends Effect

var power_delta: float = 0.1
var power_max: float = 0.5
var power: float = 0

func on_set_owner(old, new):
	if old:
		owner.health.change.disconnect(on_change_health)
	if new:
		new.health.change.connect(on_change_health)

func on_change_health(comp: StatComponent, old: float, new: float):
	if new > old:
		power = min(power_max, power + power_delta)
		get_map().write_info(
			"=> Падший ангел усилен до " + str(int(power*100)) + "% (" + owner.unit_name + ")"
		)

func update_on_attack(_damage: float, _instigator: Node = null) -> float:
	_damage *= (1 + power)
	print("=> Up damage on ", power, " by ", effect_name)
	power = 0
	return _damage
