class_name Encounter extends TileEvent

@onready var game: Game = get_tree().root.get_child(0)
var inventory: Inventory

@export var enemies: Array[PackedScene]

"""
represents encounter
you must put an instance of this scene into the strat_map scene
then you should define opponents in enemies array 
(just set size and drag the scene into the slots)
and texture 
(again, just drag the texture into the slot)
"""

func activate():
	game = get_tree().root.get_child(0)
	inventory = game.strat_map.player.inventory
	var characters = inventory.characters
	game.tactical_map.reinit(characters, enemies)
	game.tactical_map.finish.connect(on_finish_tactical_map)
	game.to_tact_mode()
	
func on_finish_tactical_map(alive: Array[PackedScene], dead: Array[PackedScene]):
	inventory.characters = alive
	game.to_strat_mode()
	remove()
	for char_p in dead:
		var char = char_p.instantiate()
		if char.name == game.strat_map.player.mc_name:
			game.strat_map.show_game_over()
