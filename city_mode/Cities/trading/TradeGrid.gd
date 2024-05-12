extends GridContainer

signal item_changed

#@onready var game: Game = get_tree().root.get_child(0)
#@onready var inventory : Inventory = game.strat_map.player.inventory
var inventory : Inventory = null:
	set(value):
		inventory = value
		
		if value != null:
			update()
			print(inventory)

#func _ready():
	#update()

func update():
	for i in get_children():
		i.item = null
		i.stack = 0
	var keys = inventory.items.keys()
	for i in keys:
		#await get_tree().create_timer(0.0001).timeout
		add_item(i, inventory.items[i], i.max_stack)
	item_changed.emit()

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

func how_much(item):
	var st : int = 0
	for i in get_children():
		if i.item == item:
			st += i.stack
	return st

func check_item(item, stack):
	for i in get_children():
		if item == i.item and item.max_stack - i.stack >= stack:
			return 0
	return 1

func free_slots():
	var free_slots: int = 0 
	for i in get_children():
		if i.item == null:
			free_slots += 1
	return free_slots