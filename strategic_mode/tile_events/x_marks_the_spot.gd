extends "res://strategic_mode/tile_events/TileEvent.gd"

@onready var inventory: Inventory = preload("res://inventory/global_inventory.tres")
@onready var coin: Item = preload("res://inventory/items/coin.tres")


func activate():
	inventory.insert(coin, 1000)
	remove()

func remove():
	var host = get_parent()
	host.remove_child(self)
