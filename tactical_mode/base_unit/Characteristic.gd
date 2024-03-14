class_name Characteristic

var base: float
var cur: float
var max_: float

func _init(_base: float, _cur: float, _max: float):
	base = _base
	cur = _cur
	max_ = _max

func percent() -> float:
	return max(max_, base) / cur

func set_cur(value: float):
	cur = max(0, min(max_, value))

