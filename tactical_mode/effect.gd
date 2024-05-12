class_name Effect extends Resource

@export var texture: Texture2D
@export var mods: Array[Mod] = []
@export var destroy_on_death_instigator: bool = false
@export var stackable = false

signal finished(Effect)
signal updated_mods

@export var effect_name: String = "Эффект"
@export var is_negative: bool = false
@export var visual_effect: PackedScene

var _visual_effect: Node

var owner: Unit = null:
	set(value):
		if not _visual_effect and visual_effect:
			_visual_effect = visual_effect.instantiate()
			finished.connect(remove_visual_effect)
		var old = owner
		owner = value
		if _visual_effect:
			if old:
				old.death.disconnect(remove_visual_effect)
				old.remove_child(_visual_effect)
			if owner:
				owner.death.connect(remove_visual_effect)
				owner.add_child(_visual_effect)
		 
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

func remove_visual_effect(_null=null):
	if _visual_effect and owner:
		owner.remove_child(_visual_effect)
