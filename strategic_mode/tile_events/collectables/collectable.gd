class_name Collectable extends TileEvent

"""
Tile event that can be placed on teh TileMap
Abstract parent for all collectables
"""

@onready var game: Game = get_tree().root.get_child(0)
@onready var inventory: Inventory = game.strat_map.player.inventory

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
