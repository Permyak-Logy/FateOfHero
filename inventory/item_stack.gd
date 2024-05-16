extends Resource
"""
represents the thing you pick in the inventory
item - stack of that item
size - number of items in the stack RIGHT NOW
note, that it is just data. It cannot be seen on it's own
"""
class_name ItemStack

@export var item: Item
@export var size: int

static func create(item_: Item, size_: int) -> ItemStack:
	assert(item_ != null)
	assert(size_ > 0)
	assert(size_ <= item_.max_stack, "can't create itemstack with size > max_stack_size")
	var item_stack: ItemStack = ItemStack.new()
	item_stack.item = item_
	item_stack.size = size_
	return item_stack
