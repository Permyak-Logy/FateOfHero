class_name IttoP1 extends Effect

@export var power: float = 20
@export var percent: float = 0.4
@export var cooldown: int = 0
@export var cooldown_time: int = 3
	
func update_on_start_stepmove():
	if cooldown:
		cooldown -= 1
		return

	var map = owner.get_map()
	var units: Array[Unit]
	if map.is_player(owner):
		units = map.get_player_units()
	else:
		units = map.get_enemy_units()
	
	for unit in units:
		if unit == owner:
			continue
		if unit.health and 0 < unit.health.percent() and unit.health.percent() <= percent:
			var diff = -unit.health.cur()
			unit.health.add(power)
			diff += unit.health.cur()
			cooldown = cooldown_time
			get_map().write_info(
				"=> Восстанавливает " + diff + " здоровья у " + 
				unit.unit_name + " (" + effect_name + ")"
				)
			return
	

func update_on_damage(_damage: float, _instigator: Node = null) -> float:
	var diff = min(power, _damage)
	_damage -= diff
	power -= diff
	if power <= 0:
		finished.emit(self)
	return _damage
