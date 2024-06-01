class_name InventoryComponent extends Resource

const DEFAULT_COUNT_SLOTS = 1

@export var _gears: Dictionary # Dict[Gear.Type, [Gear]]
@export var _abilities: Array[Ability] = []
@export var gear_slots = { 
	Gear.Type.Hands: 2
}
@export var ability_slots: int = 5


func use(stack: ItemStack) -> int:
	var item = stack.item as Item
	if not item or stack.size <= 0:
		return 0
	
	if is_instance_of(item, Ability):
		fixup_abilities()
		
		var ability = item as Ability
		if len(_abilities) >= ability_slots:
			return 0
		
		_abilities.append(ability)
		
		if ability.consumable:
			ability.count = stack.size
			return stack.size
		return 1
	
	if is_instance_of(item, Gear):
		var gear = item as Gear
		var count = min(stack.size, 1)
		if count <= 0:
			return 0
		
		var limit = gear_slots.get(gear.type, DEFAULT_COUNT_SLOTS)
		if not _gears.has(gear.type):
			_gears[gear.type] = []
	
		if len(_gears[gear.type]) >= limit:
			return 0
		_gears[gear.type].append(gear.duplicate(true))
		return count
	
	return 0

func unuse(stack: ItemStack) -> int:
	var item = stack.item as Item
	if not item or stack.size <= 0:
		return 0
		
	if is_instance_of(item, Ability):
		var count = 1
		var ability = item as Ability
		if not _abilities.has(ability):
			return 0
		_abilities.erase(ability)
		if ability.consumable:
			count = max(ability.count, 0)
			ability.count = 0
		return count
	
	if is_instance_of(item, Gear):
		var gear = item as Gear
		if not _gears.has(gear.type):
			return 0
		if not _gears[gear.type].has(gear):
			return 0
		_gears[gear.type].erase(gear)
		return 1
	return 0

func get_gears(gear_type: Gear.Type) -> Array[Gear]:
	var res: Array[Gear] = []
	for gear in  _gears.get(gear_type, []):
		res.append(gear)
		#var ability = gear as Ability
		#var stack = ItemStack.create(gear, 1 if not ability or not ability.consumable else ability.count)
		#if stack.size > 0:
		#	res.append(stack)
	return res

func fixup_abilities():
	var to_remove: Array[Ability] = []
	for elem in _abilities:
		if elem.consumable and elem.count == 0:
			to_remove.append(elem)
		
	for elem in to_remove:
		_abilities.erase(elem)

func get_abilities() -> Array[Ability]:
	fixup_abilities()
	var res: Array[Ability] = []
	for elem in _abilities:
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

func get_effects() -> Array[Effect]:
	var effects: Array[Effect] = []
	for gears in _gears.values():
		for gear in gears:
			for effect in gear.get_effects():
				effects.append(effect)
	return effects
