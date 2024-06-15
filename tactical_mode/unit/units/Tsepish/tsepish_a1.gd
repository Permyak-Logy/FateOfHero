class_name TsepishA1 extends DirectedAbility

@export var distance: int = 2

func apply():
	pass

func can_select(target: Actor):
	if not super(target):
		return false
	if not is_instance_of(target, Unit):
		return false
	return true

func cell_to_hook(t: Unit):
	var d = owner.global_position - t.global_position
	if d[0] > 0 and d[1] > 0:
		pass # TODO
	AStarHexagon2D.DIRECTIONS[AStarHexagon2D.DirsE.LeftUp]

func fill_overlay() -> Array[Vector2i]:
	var res: Array[Vector2i] = []
	var map = get_map()
	var cell = (owner as Actor).get_cell()
	for _cell in map._astar_board._cells:
		if map.distance_between_cells(_cell, cell) <= distance and _cell != cell:
			res.append(_cell)
	return res
