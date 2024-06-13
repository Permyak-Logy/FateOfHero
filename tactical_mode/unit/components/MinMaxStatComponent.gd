class_name MinMaxStatComponent extends StatComponent

enum ScalingType {Min, Max}

@export var _max_p: float = 1
@export var _min_p: float = 0
@export var _scaling: ScalingType = ScalingType.Max

signal empty(comp: StatComponent)
signal full(comp: StatComponent)

func percent() -> float:
	if _max_p - _min_p == 0:
		return 1.
	return _cur / (get_max() - get_min())

func get_max() -> float:
	if _scaling == ScalingType.Max:
		return max(get_min(), _max_p * mod_value.mul + mod_value.add)
	return _base * _min_p

func get_min() -> float:
	if _scaling == ScalingType.Min:
		return min(get_max(), _min_p * mod_value.mul + mod_value.add)
	return _base * _max_p

func set_cur(value):
	super(max(get_min(), min(get_max(), value)))
	if cur() == get_min():
		empty.emit(self)
	if cur() == get_max():
		full.emit(self)

func rebase(value: float):
	var p = percent()
	super(value)
	_cur = _cur * p - get_min()
