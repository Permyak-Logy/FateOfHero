class_name StatComponent extends Resource


@export var mod_type: Mod.Type = Mod.Type.None
@export var _base: float

var mod_value: ModValue = ModValue.new(0, 0)

func cur():
	return _base * (mod_value.mul + 1) + mod_value.add

func rebase(new_base: float):
	_base = new_base

func reload_mods(unit: Unit):
	mod_value.clear()
	var _mods = unit.get_mods()
	var _mod = _mods.get(mod_type, ModValue.new())
	mod_value.iadd(_mod)
	rebase(_base)
