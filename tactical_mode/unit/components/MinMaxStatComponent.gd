class_name MinMaxStatComponent extends StatComponent

enum ScalingType {Min, Max}

@export var _max_p: float = 1
@export var _min_p: float = 0
@export var _cur: float = 0
@export var _scaling: ScalingType = ScalingType.Max

signal change(comp: MinMaxStatComponent, old: float, new, float)
signal empty(comp: MinMaxStatComponent)
signal full(comp: MinMaxStatComponent)

func percent() -> float:
	if _max_p - _min_p == 0:
		return 1.
	return (_cur - get_min()) / (get_max() - get_min())

func get_max() -> float:
	if _scaling == ScalingType.Max:
		return max(
			get_min(),
			_max_p * _base * (mod_value.mul + 1) + mod_value.add
		)
	return _base * _max_p

func get_min() -> float:
	if _scaling == ScalingType.Min:
		return min(
			get_max(),
			_min_p * _base * (mod_value.mul + 1) + mod_value.add
		)
	return _base * _min_p

func set_cur(value):
	var old = _cur
	_cur = max(get_min(), min(get_max(), value))
	if old != _cur:
		change.emit(self, old, _cur)	
	if cur() == get_min():
		empty.emit(self)
	if cur() == get_max():
		full.emit(self)

func rebase(value: float):
	var p = percent()
	super(value)
	_cur = _cur * p - get_min()

func add(value: float):
	set_cur(_cur + value)

func sub(value: float):
	set_cur(_cur - value)
