class_name AttackAbility extends DirectedAbility
@export var distance: int = 1
@export var power_p: float = 1

func apply():
	var unit = selected[0] as Unit
	if owner.damage:
		await (owner as Unit).play("preattack", unit)
		await (owner as Unit).play("attack")
		var damaged = await unit.apply_damage(owner.damage.cur(), owner)
		await (owner as Unit).play("postattack")
		owner.play("idle")
		return true
	return false

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	if get_map().is_player(owner) == get_map().is_player(node):
		return false
	var cur_dist = float("inf")
	for cell in unit.get_occupied_cells():
		cur_dist = min(cur_dist, get_map().distance_between_cells(owner.get_cell(), cell))
	return cur_dist <= distance

func fill_overlay() -> Array[Vector2i]:
	var res: Array[Vector2i] = []
	var map = get_map()
	var cell = (owner as Actor).get_cell()
	for _cell in map._astar_board._cells:
		if map.distance_between_cells(_cell, cell) <= distance and _cell != cell:
			res.append(_cell)
	return res
