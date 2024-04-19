extends Node

class_name InventoryComponent

# for number of slots on the left 
@export var max_abilities = 3

# for number of slots on the right
@export var gear_slots: Dictionary = {
	Gear.Type.Head : 1,
	Gear.Type.Body : 1, 
	Gear.Type.Hands : 2, 
	Gear.Type.Legs : 1, 
}

@export var _gears: Dictionary # Dict[Gear.Type, [Gear]]
@onready var limits = {
	Gear.Type.Ability: max_abilities,
	Gear.Type.Hands: 2
}

func use(gear: Gear) -> bool:
	var limit = limits.get(gear.type, 1)
	if not _gears.has(gear.type):
		_gears[gear.type] = []
	if len(_gears[gear.type]) >= limit:
		return false
	_gears[gear.type].append(gear)
	($'..' as Unit).reload_all_mods()
	return true

func unuse(gear: Gear) -> bool:
	if not _gears.has(gear.type):
		return false
	_gears[gear.type].erase(gear)
	($'..' as Unit).reload_all_mods()
	return true

func get_gears(gear_type: Gear.Type) -> Array:
	return _gears.get(gear_type, [])

func get_abilities() -> Array:
	return get_gears(Gear.Type.Ability)

func get_mods() -> Dictionary:
	var all_mods = {}
	for gears in _gears.values():
		for item in gears:
			var gear: Gear = item
			var mods = gear.get_mods()
			for i in mods:
				var mod: Mod = i
				if not all_mods.has(mod.type):
					all_mods[mod.type] = ModValue.new()
				all_mods[mod.type].iadd(mod.value)
	return all_mods
