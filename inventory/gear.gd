extends "res://inventory/item.gd"

class_name Gear

enum Type {Head, Body, Hands, Legs, Ability}

@export var type: Type
@export var _mods: Array[Mod]

func get_mods() -> Array[Mod]:
	return _mods
