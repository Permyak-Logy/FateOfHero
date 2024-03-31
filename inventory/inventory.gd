extends Resource

class_name Inventory

# list of items and counts there of
@export var items: Dictionary
var characters: Array[Unit] = []
# must be equal to number of cells
const max_stacks_count: int = 50
const max_character_count: int = 5

func set_def_chars():
	var nav = preload("res://tactical_mode/base_unit/Naris/Naris.gd")
	

func get_item_stacks() -> Array[ItemStack]:
	"""
	returns array of max_stacks_countx
	"""
	var item_stacks: Array[ItemStack] = []
	var keys = items.keys()
	keys.sort_custom(Item.less)
	for item in keys:
		var count = items[item]
		
		for i in range(count / item.max_stack):
			item_stacks.push_back(ItemStack.new(item, item.max_stack))
		if count % item.max_stack:
			item_stacks.push_back(ItemStack.new(item, count % item.max_stack))
	return item_stacks

func get_stack_count():
	var stack_count = 0
	for item in items.keys():
		stack_count += items[item] / item.max_stack + (1 if items[item] % item.max_stack else 0)
	return stack_count

func insert(item: Item, count: int) -> int:
	"""
	inserts <count> items into inventery 
	returns number of items that weren't able to be inserted
	"""
	assert(item)
	assert(item.max_stack > 0)
	if count == 0: return 0
	
	var stack_count = get_stack_count()
	if not item in items.keys():
		items[item] = 0
	
	var full_stacks: int = count / item.max_stack
	
	if full_stacks + 1 + stack_count < max_stacks_count:
		#everything fits in
		items[item] += count 
		return 0
	#fills up completely
	items[item] += item.max_stack * (max_stacks_count - stack_count)
	return count - item.max_stack * (max_stacks_count - stack_count)

func remove(item: Item, count: int):
	if not item in items.keys(): return
	if count == 0: return
	assert(count <= items[item], "can't remove more than in inventory")
	items[item] -= count 
	if items[item] == 0:
		items.erase(item) 


