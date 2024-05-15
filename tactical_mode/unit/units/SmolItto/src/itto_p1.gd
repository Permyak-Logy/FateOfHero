class_name IttoP1 extends Effect

@export var power: ModValue
@export var percent: float = 0.4
@export var cooldown: int = 3
var cooldown_time: int = 0
	
func update_on_start_stepmove():
	if cooldown_time:
		cooldown_time -= 1
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
			unit.health.iadd(owner.health.get_max() * power.mul + power.add)
			diff += unit.health.cur()
			cooldown_time = cooldown
			get_map().write_info(
				"=> Восстанавливает " + str(diff) + " здоровья у " + 
				unit.unit_name + " (" + effect_name + ")"
				)
			return
