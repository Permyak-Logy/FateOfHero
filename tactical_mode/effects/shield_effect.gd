class_name ShieldEffect extends Effect

@export var power: ModValue
@export var scaling_type: Mod.Type

var strength: float
var scale: float:
	get:
		return (instigator as Unit).stat_from_type(scaling_type).cur()

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
