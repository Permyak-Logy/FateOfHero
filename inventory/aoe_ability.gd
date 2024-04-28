class_name AoEAbility extends Ability

@export var overlay_atlas_coords: Vector2i = Vector2i(1, 0)

var cell: Vector2i = Vector2i(-1, -1)
var about_cells: Array[Vector2i] = []

func select_cell(_cell: Vector2i):
	cell = _cell
	find_about_cells()

func unselect_cell():
	cell = Vector2i(-1, -1)
	about_cells.clear()

func apply():
	for unit in get_map().units:
		var cell = unit.get_cell()
		if cell in about_cells or (unit.cells_occupied == 2 and cell + Vector2i(1, 0) in about_cells):
			apply_on_unit(unit)

func apply_on_unit(unit: Unit):
	pass

func find_about_cells():
	about_cells.clear()
	about_cells.append(cell)

func clear():
	cell = Vector2i(-1, -1)
	about_cells.clear()

func can_select_cell(_cell: Vector2i) -> bool:
	return get_map()._astar_board.has_cell(_cell)

func can_apply() -> bool:
	return get_map()._astar_board.has_cell(cell)
