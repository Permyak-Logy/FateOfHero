class_name Collectable extends TileEvent

"""
Tile event that can be placed on teh TileMap
Abstract parent for all collectables
"""

var game: Game
var inventory: Inventory

var item: Resource 
var count: int


func init():
	pass

func _ready():
	init()
	assert(item != null, "collectables need their values refefined in seperate script")
	assert(count != null, "collectables need their values refefined in seperate script")

func activate():
	game = get_tree().root.get_child(0)
	inventory = game.strat_map.player.inventory
	inventory.insert(item, count)
	remove()

func remove():
	var host = get_parent()
	host.remove_child(self)
