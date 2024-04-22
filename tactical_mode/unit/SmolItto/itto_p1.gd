class_name IttoP1 extends Effect

var power: float
var percent: float
var cooldown: int = 0
var cooldown_time: int

func _init(_instigator, _power: float = 20, _percent: float = 0.4, _cooldown_time: int = 3):
	super(_instigator)
	power = _power
	percent = _percent
	cooldown_time = _cooldown_time
	
func update_on_move():
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
			unit.health.add(power)
			cooldown = cooldown_time
			print("=> IttoP1 heal ", power, " for ", unit.unit_name)
			return
	

func update_on_damage(_damage: float, _instigator: Node = null) -> float:
	var diff = min(power, _damage)
	_damage -= diff
	power -= diff
	if power <= 0:
		finished.emit(self)
	return _damage
