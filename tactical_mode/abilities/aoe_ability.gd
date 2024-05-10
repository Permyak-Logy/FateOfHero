class_name AoEAbility extends Ability

@export var only_auto_select = false

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
		for cell in unit.get_occupied_cells():
			if cell in about_cells:
				print(".0||||", owner, len(owner.death.get_connections()))
				apply_on_unit(unit)
				print("..0||||", owner, len(owner.death.get_connections()))
				break
	print("0||||", owner, len(owner.death.get_connections()))

func apply_on_unit(unit: Unit):
	pass

func fill_overlay() -> Array[Vector2i]:
	return about_cells

func find_about_cells():
	about_cells.clear()
	about_cells.append(cell)

func clear():
	cell = Vector2i(-1, -1)
	about_cells.clear()

func default_cell():
	return (owner as Unit).get_cell()

func can_select_cell(_cell: Vector2i) -> bool:
	return get_map()._astar_board.has_cell(_cell)

func can_apply() -> bool:
	return get_map()._astar_board.has_cell(cell)
