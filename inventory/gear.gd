class_name Gear extends Item

enum Type {Head, Body, Hands, Legs}

@export var type: Type
@export var _mods: Array[Mod]
@export var _effects: Array[Effect]

func get_mods() -> Array[Mod]:
	return _mods

func get_effects() -> Array[Effect]:
	return _effects
