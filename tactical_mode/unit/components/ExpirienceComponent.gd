class_name ExpirienceComponent extends Node

var level: int = 1
var expirience: int = 0

func get_exp_to_next_lvl() -> int:
	return 100

func add_exp(_exp: int):
	expirience += _exp
	while expirience >= get_exp_to_next_lvl():
		level_up()

func level_up():
	pass
