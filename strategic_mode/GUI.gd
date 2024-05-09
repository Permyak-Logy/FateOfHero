class_name StratMapGUI extends CanvasLayer
"""
invisible node in the strat map
Any GUI should be it's child.
"""
@onready var inventory: InventoryGUI = $InventoryGUI

var busy = false

func _input(event):
	if busy:
		return
	if event.is_action_pressed("inv_button"): 
		if not inventory.is_open:
			inventory.open()
		else:
			inventory.close()
	if event.is_action_pressed("escape"):
		if inventory.is_open:
			inventory.close()

