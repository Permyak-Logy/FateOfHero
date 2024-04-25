extends DialogueOption

@export var new_pos: Vector2i = Vector2i(0, 0)

func activate():
	game.strat_map.player.move_to(new_pos)
	dialog_action_done.emit(next_dialogue)
