extends HBoxContainer

class_name Sale

@export var sale_inventory: Inventory = null

func update():
	for i in get_children():
		i.item = null
		i.stack = 0
	var keys = sale_inventory.items.keys()
	for i in keys:
		#await get_tree().create_timer(0.0001).timeout
		add_item(i, sale_inventory.items[i], i.max_stack)

func add_item(item, item_stack, item_maxstack):
	for i in get_children():
		if i.item == item and i.stack + item_stack <= item_maxstack:
			i.stack += item_stack
			return
		elif i.item == item:
			item_stack = item_stack + i.stack - item_maxstack
			i.stack = item_maxstack
	for i in get_children():
		if i.item == null and item_stack <= item_maxstack:
			i.item = item
			i.max_stack = item_maxstack
			i.stack += item_stack
			return
		elif i.item == null:
			i.item = item
			i.max_stack = item_maxstack
			item_stack = item_stack - item_maxstack
			i.stack = item_maxstack

func check_place(item):
	for i in get_children():
		if i.item == item and i.stack < item.max_stack or i.item == null:
			return true
	return false

func get_price():
	var price = 0
	for i in get_children():
		if i.item != null:
			price += i.item.price*i.stack
	return price

func clear():
	for i in sale_inventory.items.keys():
		sale_inventory.remove(i, sale_inventory.items[i])
	update()
