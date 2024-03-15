extends CanvasLayer
@onready var inventory = $InventoryGUI
func _input(event):
	if event.is_action_pressed("inv_button"): 
		if not inventory.is_open:
			inventory.open()
		else:
			inventory.close()

