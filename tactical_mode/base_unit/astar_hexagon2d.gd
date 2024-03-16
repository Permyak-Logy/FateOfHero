extends AStar2D

class_name AStarHexagon2D

const _MOD_CELL_ID = 1000 
# Первый набор для чётных Y координат, второй для нечётных
const DIRECTIONS = [
	[
		Vector2i(-1, -1), Vector2i(0, -1),
		Vector2i(-1, 0), Vector2i(1, 0),
		Vector2i(-1, 1), Vector2i(0, 1)
	], [
		Vector2i(0, -1), Vector2i(1, -1), 
		Vector2i(-1, 0), Vector2i(1, 0), 
		Vector2i(0, 1), Vector2i(1, 1)
	]
]

var _cells: Array

func _init(cells: Array):
	_cells = cells
	for cell in cells:
		add_point(mti(cell), cell)
	for cell in cells:
		var cell_id = mti(cell) 
		for direction in DIRECTIONS[cell[1] % 2]:
			var other = cell + direction
			if other in cells:
				connect_points(cell_id, mti(other), false)

func has_cell(cell: Vector2i) -> bool:
	return has_point(mti(cell))

func mti(cell: Vector2i) -> int:
	return cell[0] * _MOD_CELL_ID + cell[1] % _MOD_CELL_ID

func itm(cell: int) -> Vector2i:
	return get_point_position(cell) as Vector2i
