extends NinePatchRect

class_name InventoryPanel

"""
The grid of cells in the inventory for the items
"""

@onready var slots = $GridContainer.get_children()
@onready var ItemStackReprClass = preload("res://inventory/item_stack_repr.tscn")

func update(item_stacks: Array[ItemStack]):
	for slot in slots:
		slot.item_stack_repr = null
		slot.update()
	
	for i in range(min(item_stacks.size(), slots.size())):
		var item_stack: ItemStack = item_stacks[i]
		var item_stack_repr: ItemStackRepr = slots[i].item_stack_repr
		if not item_stack_repr:
			item_stack_repr = ItemStackReprClass.instantiate()
			slots[i].insert(item_stack_repr)
		item_stack_repr.item_stack = item_stack
		item_stack_repr.update()
	
	for slot in slots:
		slot.update()
