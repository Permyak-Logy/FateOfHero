class_name TeleportAbility extends AoEAbility

func apply():
	await owner.play("preteleport")
	get_map().move_unit_to(owner, cell)
	await owner.play("postteleport")

func can_select(_cell: Vector2i) -> bool:
	if not get_map()._astar_board.has_cell(_cell):
		return false
	if get_map().is_occupied(_cell):
		return false
	return true

