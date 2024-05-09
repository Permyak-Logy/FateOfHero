class_name MicroInventory extends Resource

"""
One slot incentory for... various needs
"""

# list of items and counts there of
@export var contents: ItemStack = null
#const max_character_count: int = 5

func get_item_stacks() -> Array[ItemStack]:
	return [contents]

func get_stack_count() -> int:
	return 1 if contents else 0

func insert(item: Item, count: int) -> int:
	"""
	inserts <count> items into inventery 
	returns number of items that weren't able to be inserted
	"""
	assert(item)
	assert(item.max_stack > 0)
	if count == 0: return 0
	if not contents:
		contents = ItemStack.new(item, count)
	if contents.item != item: 
		return count
	if contents and contents.size + count > item.max_stack:
		return contents.size + count - item.max_stack
	contents.size += count
	return 0

func insert_is(item_stack: ItemStack) -> int:
	return insert(item_stack.item, item_stack.size)

func remove(item: Item, count: int):
	if item != contents.item: return
	if count == 0: return
	assert(count <= contents.size,"can't remove more than in inventory")
	contents.size -= count 
	if contents.size == 0:
		contents = null

func remove_is(item_stack: ItemStack):
	return remove(item_stack.item, item_stack.size)
