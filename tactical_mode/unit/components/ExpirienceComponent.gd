class_name ExpirienceComponent extends Resource

@export var level: int = 1
@export var expirience: int = 0
@export var ups: int = 0


func get_exp_to_next_lvl() -> int:
	return int(100 * exp((level - 1) / 40))

func add_exp(_exp: int):
	expirience += _exp
	
	while expirience >= get_exp_to_next_lvl():
		expirience -= get_exp_to_next_lvl()
		level += 1
		ups += 1
	
func accept_level_up():
	ups -= 1

func can_level_up() -> bool:
	return ups > 0
