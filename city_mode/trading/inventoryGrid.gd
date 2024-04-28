extends GridContainer

signal item_changed

@export var inventory : Inventory

#import_inventory
func _ready():
	var keys = inventory.items.keys()
	for i in keys:
		await get_tree().create_timer(0.00001).timeout
		add_item(i, inventory.items[i], i.max_stack)

func add_item(item, item_stack, item_maxstack):
	for i in get_children():
		if i.item == item and i.stack + item_stack <= item_maxstack:
			i.stack += item_stack
			item_changed.emit()
			return
		elif i.item == item:
			item_stack = item_stack + i.stack - item_maxstack
			i.stack = item_maxstack
	for i in get_children():
		if i.item == null and item_stack <= item_maxstack:
			i.item = item
			i.max_stack = item_maxstack
			i.stack += item_stack
			item_changed.emit()
			return
		elif i.item == null:
			i.item = item
			i.max_stack = item_maxstack
			item_stack = item_stack - item_maxstack
			i.stack = item_maxstack

func remove_item(item, item_stack, item_maxctack):
	for i in get_children():
		if i.item == item and i.stack < item_maxctack and item_stack < i.stack:
			i.stack -= item_stack
			if i.stack == 0:
				i.item = null
				i.max_stack = 0
			item_changed.emit()
			return
	for i in get_children():
		if i.item == item:
			i.stack -= item_stack
			if i.stack == 0:
				i.item = null
				i.max_stack = 0
			item_changed.emit()
			return
 
func is_available(item):
	for i in get_children():
		if i.item == item:
			return true
	return false

func how_much(item):
	for i in get_children():
		if i.item == item:
			return i.stack
	return 0

func sort_items():
	var item : Item
	var stack : int
	var max_stack : int
	for i in get_children():
		item = i.item
		stack = i.stack
		max_stack = i.max_stack
		remove_item(item, stack, max_stack)
		add_item(item, stack, max_stack)
