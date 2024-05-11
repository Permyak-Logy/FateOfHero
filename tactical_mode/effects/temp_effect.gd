class_name TempEffect extends Effect

@export_flags("ResetMoves:1", "SumMods:2") var on_stack = 0
@export var limit_stacks_for_sum_mods: int = -1
@export var moves: int = 1

func update_on_start_stepmove():
	moves -= 1
	if moves == 0:
		finished.emit()
	else:
		get_map().write_info(
			"=> " + owner.unit_name + " под эффектом " + effect_name
		)

func stack(other: Effect) -> bool:
	if on_stack & 1:
		moves = max(moves, other.moves)
	if limit_stacks_for_sum_mods != 0 and on_stack & 2:
		mods += other.mods
	limit_stacks_for_sum_mods -= 1
	return true
