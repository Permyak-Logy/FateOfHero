extends Resource

class_name ModValue

@export var add: float = 0.
@export var mul: float = 0.

func _init(_add = 0., _mul = 0.):
	add = _add
	_mul = _mul

func clear():
	add = 0
	mul = 0
