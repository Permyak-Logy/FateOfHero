extends Node2D

@onready var tactical_map: TacticalMap = $"res://tactical_mode/tactical_map.tscn"
@onready var inventory: Inventory = preload("res://inventory/global_inventory.tres")

func activate():
	characters = inventory.characters
	
	remove()

func remove():
	var host = get_parent()
	host.remove_child(self)
