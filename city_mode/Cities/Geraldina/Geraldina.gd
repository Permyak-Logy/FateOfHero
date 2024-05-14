class_name Geraldina extends City

@onready var game: Game = get_tree().root.get_child(0)
@onready var inventory = $InventoryGUI
@onready var trading = $Trading
@onready var crafting = $Crafting

func _on_button_exit_pressed():
	trading.clear()
	crafting.clear()
	game.to_strat_mode()
	#pass


func _input(event):
	if event.is_action_pressed("inv_button"): 
		if not inventory.is_open:
			inventory.open()
			if trading.visible:
				trading.visible = false
			if crafting.visible:
				crafting.visible = false
		else:
			inventory.close()


func _on_button_trading_pressed():
	var inventory = $Trading/HBoxContainer/inventory/inventoryGrid1
	if trading.visible:
		trading.visible = false
	elif !crafting.visible:
		trading.visible = true
		inventory.update()
	else:
		crafting.visible = false
		trading.visible = true
		inventory.update()

func _on_button_crafting_pressed():
	var inventory = $Crafting/HBoxContainer/inventory/inventoryGrid
	if crafting.visible:
		crafting.visible = false
	elif !trading.visible:
		crafting.visible = true
		inventory.update()
	else:
		trading.visible = false
		crafting.visible = true
		inventory.update()
