extends DialogueOption

var team: Array[PackedScene] = [
	preload("res://tactical_mode/unit/units/Naris/Naris.tscn"),
	preload("res://tactical_mode/unit/units/SmolItto/SmolItto.tscn"),
	preload("res://tactical_mode/unit/units/Vamp/Vamp.tscn"),
	preload("res://tactical_mode/unit/units/Berserk/Berserk.tscn"),
]

func activate():
	game.strat_map.player.inventory.characters.append_array(team)
	dialog_action_done.emit(next_dialogue)
	pass
