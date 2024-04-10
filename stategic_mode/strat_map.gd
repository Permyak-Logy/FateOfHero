git extends Node2D

class_name StratMap

@onready var player = $player


func pause():
	get_tree().paused = true

func unpause():
	get_tree().paused = false



func _on_inventory_gui_inventory_opened():
	pause()

func _on_inventory_gui_inventory_closed():
	unpause()
