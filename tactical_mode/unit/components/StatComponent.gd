class_name StatComponent extends Resource


@export var mod_type: Mod.Type = Mod.Type.None
@export var _base: float
@export var _cur: float:
	set(value):
		print("set _cur = ", value)
		assert(value < 10000)
		_cur = value

signal change(comp: StatComponent, old: float, new, float)
var mod_value: ModValue = ModValue.new(0, 0)

func cur():
	return _cur

func set_cur(value: float):
	print("set cur ", value)
	var old = cur()
	var _cur = value
	if old != cur():
		change.emit(self, old, _cur)

func add(value: float):
	set_cur(_cur + value)

func sub(value: float):
	set_cur(_cur - value)

func rebase(new_base: float):
	_base = new_base
	_cur = _base * (mod_value.mul + 1) + mod_value.add

func reload_mods(unit: Unit):
	mod_value.clear()
	var _mods = unit.get_mods()
	var _mod = _mods.get(mod_type, ModValue.new())
	mod_value.iadd(_mod)
	rebase(_base)
