class_name GGVampA2 extends AoEAbility

@export var power: float = 0.2

func find_about_cells():
	var map = get_map()
	
	about_cells.clear()
	for _cell in map._astar_board._cells:
		if map.distance_between_cells(_cell, cell) <= 1:
			about_cells.append(_cell)

func apply_on_unit(unit: Unit):
	print("=> Жрёт хп у ", unit, "отнято ", unit.health.cur() * power)
	unit.health.sub(unit.health.cur() * power)

func can_select_cell(_cell: Vector2i) -> bool:
	return get_map()._astar_board.has_cell(_cell)
