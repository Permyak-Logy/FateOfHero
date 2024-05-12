extends Control

class_name Trading

@export var TradingInventory : Inventory

func _ready():
	update()
	#place()

func update():
	$HBoxContainer/TradeInventory/TradeGrid.inventory = TradingInventory

func remove_item(item, num):
	TradingInventory.remove(item, num)

func add_item(item, num):
	TradingInventory.insert(item, num)

func check_place(place, inventory, item):
	return place.get_children().size() - inventory.items.size() > 0
