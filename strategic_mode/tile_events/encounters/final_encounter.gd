class_name FinalEnctounter extends Encounter


func on_finish_tactical_map(alive: Array[PackedScene], dead: Array[PackedScene]):
	inventory.characters = alive
	game.to_strat_mode()
	if game.tactical_map.win:
		game.strat_map.show_win()
		remove()
	else:
		game.strat_map.player.backtrack()
	for char_p in dead:
		var char = char_p.instantiate()
		if char.name == game.strat_map.player.mc_name:
			game.strat_map.show_game_over()
