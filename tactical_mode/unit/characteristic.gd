class_name Characteristic extends Resource

@export var base: float = 0
@export var cur: float = 0
@export var max_: float = 0

func percent() -> float:
	if max_ == 0:
		return 0
	return cur / max_

func set_cur(value: float):
	cur = max(0, min(max_, value))

