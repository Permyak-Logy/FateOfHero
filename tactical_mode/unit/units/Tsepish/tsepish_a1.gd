class_name TsepishA1 extends DirectedAbility

@export var distance: int = 7

func apply():
	var target = selected[0]
	var map = get_map()
	await target.play("move", {"path": [cell_to_hook(target)], "speed": 10})
	
func can_select(target: Actor):
	var map = get_map()
	if not super(target):
		return false
	if not is_instance_of(target, Unit):
		return false
	if map.is_occupied(cell_to_hook(target)):
		return false
	if map.distance_between_cells(target.get_cell(), owner.get_cell()) > distance:
		return false
	return true

func cell_to_hook(t: Unit):
	var d = owner.global_position - t.global_position
	var map = get_map()
	var own_cell = map.to_map(owner.global_position)
	var dir: int = 1_000_000
	if d[0] > 0 and d[1] > 0:
		dir = AStarHexagon2D.DirsE.LeftUp
	if d[0] == 0 and d[1] > 0:
		dir = AStarHexagon2D.DirsE.LeftUp
		if map.is_occupied(own_cell + dir):
			dir = AStarHexagon2D.DirsE.RightUp
	if d[0] < 0 and d[1] > 0:
		dir = AStarHexagon2D.DirsE.RightUp
	if d[0] > 0 and d[1] == 0:
		dir = AStarHexagon2D.DirsE.Right
	if d[0] < 0 and d[1] == 0:
		dir = AStarHexagon2D.DirsE.Left
	if d[0] > 0 and d[1] < 0:
		dir = AStarHexagon2D.DirsE.RightDown
	if d[0] == 0 and d[1] < 0:
		dir = AStarHexagon2D.DirsE.LeftDown
		if map.is_occupied(own_cell + dir):
			dir = AStarHexagon2D.DirsE.RightDown
	if d[0] < 0 and d[1] < 0:
		dir = AStarHexagon2D.DirsE.RightDown
	return own_cell + AStarHexagon2D.DIRECTIONS[own_cell[1] % 2][dir]

func fill_overlay() -> Array[Vector2i]:
	var res: Array[Vector2i] = []
	var map = get_map()
	var cell = (owner as Actor).get_cell()
	for _cell in map._astar_board._cells:
		if map.distance_between_cells(_cell, cell) <= distance and _cell != cell:
			res.append(_cell)
	return res
