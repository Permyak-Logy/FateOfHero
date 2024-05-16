class_name InventoryComponent extends Resource

const DEFAULT_COUNT_SLOTS = 1

@export var _gears: Dictionary # Dict[Gear.Type, [Gear]]
@export var gear_slots = { 
	Gear.Type.Ability: 5,
	Gear.Type.Hands: 2
}

func use(stack: ItemStack) -> int:
	var gear = stack.item as Gear
	if not gear:
		return 0
	
	var count = min(stack.size, 1)
	if is_instance_of(gear, Ability):
		fixup_abilities()
		var ability = gear as Ability
		if ability.consumable:
			ability.count = stack.size
			count = stack.size
	
	if count <= 0:
		return 0
	
	var limit = gear_slots.get(gear.type, DEFAULT_COUNT_SLOTS)
	if not _gears.has(gear.type):
		_gears[gear.type] = []
	
	if len(_gears[gear.type]) >= limit:
		return 0
	_gears[gear.type].append(gear.duplicate(true))
	return count

func unuse(stack: ItemStack) -> int:
	var gear = stack.item as Gear
	
	if not gear or stack.size == 0:
		return 0
	if not _gears.has(gear.type):
		return 0
	if not _gears[gear.type].has(gear):
		return 0
	
	var count = 1
	if is_instance_of(gear, Ability):
		var ability = gear as Ability
		if ability.consumable:
			count = max((gear as Ability).count, 0)
			(gear as Ability).count = 0
	_gears[gear.type].erase(gear)
	return count

func get_gears(gear_type: Gear.Type) -> Array[ItemStack]:
	if gear_type == Gear.Type.Ability:
		fixup_abilities()
	
	var res: Array[ItemStack] = []
	for gear in  _gears.get(gear_type, []):
		var ability = gear as Ability
		var stack = ItemStack.create(gear, 1 if not ability or not ability.consumable else ability.count)
		if stack.size > 0:
			res.append(stack)
	return res

func fixup_abilities():
	var to_remove: Array[Ability] = []
	for elem in get_abilities():
		if elem.consumable and elem.count == 0:
			to_remove.append(elem)
		
	for elem in to_remove:
		_gears[Gear.Type.Ability].erase(elem)

func get_abilities() -> Array[Ability]:
	var res: Array[Ability] = []
	for elem in _gears.get(Gear.Type.Ability, []):
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
