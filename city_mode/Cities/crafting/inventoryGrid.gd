extends GridContainer

signal item_changed

#@onready var game: Game = get_tree().root.get_child(0)
#@onready var inventory : Inventory = game.strat_map.player.inventory
@export var inventory : Inventory

func _ready():
	update()

func update():
	for i in get_children():
		i.item = null
		i.stack = 0
	var keys = inventory.items.keys()
	for i in keys:
		#await get_tree().create_timer(0.0001).timeout
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

func how_much(item):
	var st : int = 0
	for i in get_children():
		if i.item == item:
			st += i.stack
	return st
