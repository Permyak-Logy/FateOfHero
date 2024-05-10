class_name Sheeno extends City
@onready var game: Game = get_tree().root.get_child(0)
@onready var inventory = $InventoryGUI


func _on_button_exit_pressed():
	game.to_strat_mode()
	#pass


func _input(event):
	if event.is_action_pressed("inv_button"): 
		if not inventory.is_open:
			inventory.open()
			if $Trading.visible:
				$Trading.visible = false
			if $Crafting.visible:
				$Crafting.visible = false
		else:
			inventory.close()



func _on_button_trading_pressed():
	var inventory = $Trading/HBoxContainer/inventory/inventoryGrid1
	if $Trading.visible:
		$Trading.visible = false
	elif !$Crafting.visible:
		$Trading.visible = true
		inventory.update()
	else:
		$Crafting.visible = false
		$Trading.visible = true
		inventory.update()

func _on_button_crafting_pressed():
	var inventory = $Crafting/HBoxContainer/inventory/inventoryGrid
	if $Crafting.visible:
		$Crafting.visible = false
	elif !$Trading.visible:
		$Crafting.visible = true
		inventory.update()
	else:
		$Trading.visible = false
		$Crafting.visible = true
		inventory.update()
