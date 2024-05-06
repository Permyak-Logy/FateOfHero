class_name Geraldina extends City
@onready var game: Game = get_tree().root.get_child(0)
#@onready var inventory: Inventory = preload("res://inventory/global_inventory.tres")

func _on_button_exit_pressed():

	leave_city.emit()

func _on_button_crafting_pressed():
	get_tree().change_scene_to_file("res://city_mode/Cities/Geraldina/crafting/crafting.tscn")

func _on_button_trading_pressed():
	get_tree().change_scene_to_file("res://city_mode/Cities/Geraldina/trading/trading.tscn")
#@onready var inventory: InventoryGUI = $InventoryGUI
