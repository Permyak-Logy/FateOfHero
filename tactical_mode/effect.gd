class_name Effect extends Resource

@export var texture: Texture2D
@export var mods: Array[Mod] = []
@export var destroy_on_death_instigator: bool = false

signal finished
signal updated_mods

@export var effect_name: String = "Эффект"
@export var is_negative: bool = false

var _owner: Unit = null
var owner:
	get:
		return _owner
	set(value):
		var old = _owner
		_owner = value
		on_set_owner(old, _owner)

var instigator: Node = null

func _ready():
	if destroy_on_death_instigator and is_instance_of(instigator, Unit):
		(instigator as Unit).death.connect(func (_x) : finished.emit(self))

func on_set_owner(old: Unit, new: Unit):
	pass

func set_instigator(_i: Node):
	instigator = _i

func update_on_move():
	"""Вызывается перед каждым ходом (но не действием)"""
	pass

func update_on_damage(damage: float, _instigator: Node = null) -> float:
	"""Вызывается перед получением любого урона. Возвращает новый урон."""
	return damage

func update_on_attack(damage: float, _recipient: Node = null) -> float:
	"""Вызывается перед каждой производимой атакой. Возвращает новый урон атаки."""
	return damage
	
func is_active() -> bool:
	return true

func get_mods() -> Array[Mod]:
	return mods
