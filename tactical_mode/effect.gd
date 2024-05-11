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

var instigator: Node = null:
	set(value):
		if destroy_on_death_instigator:
			if instigator and is_instance_of(instigator, Unit):
				instigator.death.disconnect(on_death_instigator)
			if value and is_instance_of(value, Unit):
				value.death.connect(on_death_instigator)
		instigator = value

func on_death_instigator(_inst):
	finished.emit(self)

func on_set_owner(old: Unit, new: Unit):
	pass

func update_on_start_stepmove():
	"""Вызывается перед каждым ходом (но не действием)"""
	pass

func update_on_move(distance: float) -> float:
	"""Вызывается перед получением кол-ва клеток для передвижения"""
	return distance

func update_on_damage(damage: float, _instigator: Node = null) -> float:
	"""Вызывается перед получением любого урона. Возвращает новый урон."""
	return damage

func update_on_attack(damage: float, _recipient: Node = null) -> float:
	"""Вызывается перед каждой производимой атакой. Возвращает новый урон атаки."""
	return damage

func stack(other: Effect) -> bool:
	return stackable

func is_active() -> bool:
	return true

func get_mods() -> Array[Mod]:
	return mods

func get_map() -> TacticalMap:
	return owner.get_map()

func cancel_effect():
	pass
