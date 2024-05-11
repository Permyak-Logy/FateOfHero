class_name AttackAbility extends DirectedAbility
@export var distance: int = 1
@export var power_p: float = 1

func apply():
	var unit = selected[0] as Unit
	if owner.damage:
		get_map().write_info("=> " + owner.unit_name + " атакует")
		await (owner as Unit).play("preattack", unit)
		var damaged = await unit.apply_damage(owner.damage.cur() * power_p, owner)
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
	if not unit.visible:
		return false
	if get_map().get_relation(owner, unit) != TacticalMap.relation.Enemy:
		return false
	var cur_dist = 1_000_000
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
