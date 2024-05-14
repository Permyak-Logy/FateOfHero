extends Control

class_name Trading

@onready var game: Game = get_tree().root.get_child(0)
@onready var city: City = $".."
@onready var trading_inventory: Inventory = city.trading_inventory

func _ready():
	update()

func update():
	$HBoxContainer/TradeInventory/TradeGrid.inventory = trading_inventory

func remove_item(item, num):
	trading_inventory.remove(item, num)

func add_item(item, num):
	trading_inventory.insert(item, num)

func check_place(place, inventory, item):
	return place.get_children().size() - inventory.items.size() > 0

func clear():
	var sale = $HBoxContainer/Trade/VBoxContainer/sale
	var buy = $HBoxContainer/Trade/VBoxContainer/buy
	var inventory_grid = $HBoxContainer/inventory/inventoryGrid1
	for i in sale.get_children():
		if i.item != null:
			inventory_grid.inventory.insert(i.item, i.stack)
	sale.clear()
	for i in buy.get_children():
		if i.item != null:
			trading_inventory.insert(i.item, i.stack)
	buy.clear()
	#inventory_grid.update()
	#update()

