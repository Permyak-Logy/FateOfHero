class_name StatComponent extends Resource


@export var mod_type: Mod.Type = Mod.Type.None
@export var characteristic: Characteristic


signal empty(comp: StatComponent)
signal full(comp: StatComponent)
signal change(comp: StatComponent, old: float, new, float)
var mod_value: ModValue = ModValue.new(0, 0)

func percent():
	return characteristic.percent()

func cur():
	return characteristic.cur

func get_max() -> float:
	return characteristic.max_

func get_base():
	return characteristic.base

func set_cur(value):
	var old = cur()
	characteristic.set_cur(value)
	if old != cur():
		change.emit(self, old, cur())
	
	if cur() == 0:
		empty.emit(self)
	if cur() == get_max():
		full.emit(self)

func add(value: float):
	set_cur(characteristic.cur + value)

func sub(value: float):
	set_cur(characteristic.cur - value)

func rebase(value: float, save_percent: bool = true):
	var p = percent()
	characteristic.base = value
	characteristic.max_ = characteristic.base * (mod_value.mul + 1) + mod_value.add
	if save_percent:
		characteristic.cur = characteristic.max_ * p

func reload_mods(unit: Unit, save_percent: bool = true):
	var p = percent()
	mod_value.clear()
	var _mods = unit.get_mods()
	var _mod = _mods.get(mod_type, ModValue.new())
	mod_value.iadd(_mod)
	characteristic.max_ = characteristic.base * (mod_value.mul + 1) + mod_value.add

	if save_percent:
		characteristic.set_cur(characteristic.max_ * p)
	else:
		characteristic.set_cur(characteristic.cur)



