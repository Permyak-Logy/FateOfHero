class_name ShieldEffect extends Effect

enum indicator {Base, Cur, Max}
@export var power: ModValue
@export var scaling_type: Mod.Type = Mod.Type.Health
@export var scaling_stat: indicator = indicator.Max

var strength: float

var scale: float:
	get:
		var stat = (owner as Unit).stat_from_type(scaling_type)
		if scaling_stat == indicator.Cur:
			return stat.cur()
		if scaling_stat == indicator.Base:
			return stat.get_base()
		if scaling_stat == indicator.Max:
			return stat.get_max()
		return 0

func update_on_damage(_damage: float, _instigator: Node = null) -> float:
	var diff = min(strength, _damage)
	_damage -= diff
	strength -= diff
	get_map().write_info(
		"=> Заблокировано щитом " + str(int(diff)) + " урона (" + owner.unit_name + ")"
	)
	if strength <= 0:
		finished.emit(self)
	return _damage

func is_active():
	return strength > 0

func stack(other):
	#power.iadd((other as ShieldEffect).power)
	return true
