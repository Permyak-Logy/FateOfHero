class_name StratMapGUI extends CanvasLayer
"""
invisible node in the strat map
Any GUI should be it's child.
"""
@onready var inventory: InventoryGUI = $InventoryGUI

var busy = false

func _input(event):
	if event.is_action_pressed("inv_button"): 
		if busy:
			return
		if not inventory.is_open:
			inventory.open()
		else:
			inventory.close()

