extends DialogueOption

@export var enemies: Array[PackedScene]


func is_awailable() -> bool:
	var inv: Inventory = game.strat_map.player.inventory
	return inv.characters.size() > 1

func activate():
	game.strat_map.unpause()
	var characters = game.strat_map.player.inventory.characters
	game.tactical_map.reinit(characters, enemies)
	game.tactical_map.finish.connect(on_finish_tactical_map)
	game.to_tact_mode()
	
func on_finish_tactical_map(alive: Array[PackedScene], dead: Array[PackedScene]):
	game.strat_map.player.inventory.characters = alive
	game.to_strat_mode()
	game.strat_map.pause()
	dialog_action_done.emit(next_dialogue)
