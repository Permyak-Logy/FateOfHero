class_name Effect extends Resource

@export var texture: Texture2D
@export var mods: Array[Mod] = []
@export var destroy_on_death_instigator: bool = false
@export var stackable = false

signal finished
signal updated_mods

@export var effect_name: String = "Эффект"
@export var is_negative: bool = false

var owner: Unit = null:
	set(value):
		var old = owner
		owner = value
		on_set_owner(old, owner)

var instigator: Node = null

func _ready():
	if destroy_on_death_instigator and is_instance_of(instigator, Unit):
		(instigator as Unit).death.connect(func (_x) : finished.emit(self))

func on_set_owner(old: Unit, new: Unit):
	pass

func update_on_move():
	"""Вызывается перед каждым ходом (но не действием)"""
	pass

func update_on_damage(damage: float, _instigator: Node = null) -> float:
	"""Вызывается перед получением любого урона. Возвращает новый урон."""
	return damage

func update_on_attack(damage: float, _recipient: Node = null) -> float:
	"""Вызывается перед каждой производимой атакой. Возвращает новый урон атаки."""
	return damage

func stack(other: Effect) -> bool:
	return false

func is_active() -> bool:
	return true

func get_mods() -> Array[Mod]:
	return mods

func get_map() -> TacticalMap:
	return owner.get_map()
