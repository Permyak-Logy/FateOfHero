class_name Characteristic extends Resource

@export var base: float = 0
@export var cur: float = 0
@export var max_: float = 0

func percent() -> float:
	return cur / max(max_, base) 

func set_cur(value: float):
	cur = max(0, min(max_, value))

