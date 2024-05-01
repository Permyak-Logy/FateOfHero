class_name InventoryComponent extends Resource

const DEFAULT_COUNT_SLOTS = 1

@export var _gears: Dictionary # Dict[Gear.Type, [Gear]]
@export var gear_slots = { 
	Gear.Type.Ability: 1,
	Gear.Type.Hands: 2
}

func use(gear: Gear) -> bool:
	var limit = gear_slots.get(gear.type, DEFAULT_COUNT_SLOTS)
	if not _gears.has(gear.type):
		_gears[gear.type] = []
	if len(_gears[gear.type]) >= limit:
		return false
	_gears[gear.type].append(gear)
	return true

func unuse(gear: Gear) -> bool:
	if not _gears.has(gear.type):
		return false
	_gears[gear.type].erase(gear)
	return true

func get_gears(gear_type: Gear.Type) -> Array[Gear]:
	var res: Array[Gear] = []
	for elem in  _gears.get(gear_type, []):
		res.append(elem)
	return res

func get_abilities() -> Array[Ability]:
	var res: Array[Ability] = []
	for elem in get_gears(Gear.Type.Ability):
		res.append(elem)
	return res

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
