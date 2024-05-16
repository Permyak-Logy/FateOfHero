extends DialogueOption

func activate():
	game.strat_map.player.inventory.characters.append(preload("res://tactical_mode/unit/units/SmolItto/SmolItto.tscn"))
	dialog_action_done.emit(next_dialogue)
