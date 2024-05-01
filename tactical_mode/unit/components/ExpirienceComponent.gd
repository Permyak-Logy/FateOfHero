class_name ExpirienceComponent extends Resource

@export var level: int = 1
@export var expirience: int = 0
@export var ups: int = 0

signal can_level_up

func get_exp_to_next_lvl() -> int:
	return int(100 * exp((level - 1) / 40))

func add_exp(_exp: int):
	expirience += _exp
	
	while expirience >= get_exp_to_next_lvl():
		expirience -= get_exp_to_next_lvl()
		level += 1
		ups += 1
	
	if ups:
		can_level_up.emit()

func accept_level_up():
	ups -= 1
	if ups:
		can_level_up.emit()
