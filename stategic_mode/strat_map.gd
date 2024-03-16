extends Node2D

func _on_inventory_gui_inventory_opened():
	get_tree().paused = true


func _on_inventory_gui_inventory_closed():
	get_tree().paused = false
