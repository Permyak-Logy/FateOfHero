class_name Collectable extends TileEvent

"""
Abstract parent for all collectables
"""

var game: Game
var inventory: Inventory

@export var item: Item 
@export var count: int


func init():
	pass

func _ready():
	init()
	assert(item != null, "collectables need their values refefined in seperate script")
	assert(count != null, "collectables need their values refefined in seperate script")
	sprite.texture = texture
	
func activate():
	game = get_tree().root.get_child(0)
	inventory = game.strat_map.player.inventory
	inventory.insert(item, count)
	remove()
