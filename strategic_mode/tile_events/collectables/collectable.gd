extends "res://strategic_mode/tile_events/TileEvent.gd"

"""
simplest of tile events
prototype for all collectables
"""

@onready var inventory: Inventory = preload("res://inventory/global_inventory.tres")

var item: Resource 
var count: int


func init():
	pass

func _ready():
	init()
	assert(item != null, "collectables need their values refefined in seperate script")
	assert(count != null, "collectables need their values refefined in seperate script")

func activate():
	inventory.insert(item, count)
	remove()

func remove():
	var host = get_parent()
	host.remove_child(self)
