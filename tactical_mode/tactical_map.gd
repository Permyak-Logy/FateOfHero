extends Node

class_name TacticalMap
@onready var _tile_map: TileMap = $TileMap

@onready var _astar_board = AStarHexagon2D.new(_tile_map.get_used_cells(0))
@onready var _astar_walkable: AStarHexagon2D

@onready var _current_path = PackedVector2Array()
var blocked_path = false
const _ACT_INDEX_MAX = 10000
var unit_queue = []
var acts: int

func active_unit() -> Unit:
	return unit_queue[0][1]

func _ready():
	for child in get_children():
		if is_instance_of(child, Unit):
			var unit = child as Unit
			unit_queue.append([_ACT_INDEX_MAX / unit.speed.cur(), unit])
	unit_queue.sort_custom(func(a, b): return a[0] < b[0])
	_start_stepmove()
	

func draw(layer: int, array: Array, source_id: int = -1, 
atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0):
	for coords in array:
		_tile_map.set_cell(
			layer, coords, source_id,atlas_coords, alternative_tile)

func to_map(cell: Vector2) -> Vector2i:
	return _tile_map.local_to_map(cell)
	
func to_loc(cell: Vector2i) -> Vector2:
	return _tile_map.map_to_local(cell)

func is_occupied(cell: Vector2i) -> bool:
	return cell in _tile_map.get_used_cells(3)
	
func _flood_fill(cell: Vector2i) -> Array:
	var cells = active_unit().cells_occupied
	print(active_unit().speed.cur())
	var max_distance: float = (
		active_unit().speed.cur() - 100) / 20 + 4
	var array := [cell]
	var stack := [cell, 0]
	var distance = 0
	while distance < max_distance and not stack.is_empty():
		var current = stack.pop_front()
		if not current:
			if not stack.is_empty():
				stack.append(0)
			distance += 1
			continue
		
		for next_id in _astar_board.get_point_connections(_astar_board.mti(current)):
			var next = _astar_board.itm(next_id)
			if is_occupied(next):
				continue
			if cells == 2 and (is_occupied(next + Vector2i(1, 0)) or
			not _astar_board.has_cell(next + Vector2i(1, 0))):
				continue
			if next in array:
				continue
	
			array.append(next)
			stack.append(next)

	return array

func _start_stepmove():
	acts = active_unit().acts_count
	if active_unit().controlled_player:
		_update_walkable()
	else:
		acts = 0
		_update_stepmove()

func _update_stepmove():
	if acts != 0:
		_update_walkable()
		return
	
	var time = unit_queue[0][0]
	for elem in unit_queue:
		elem[0] -= time
	unit_queue[0][0] += _ACT_INDEX_MAX / active_unit().speed.cur()
	unit_queue.sort_custom(func(a, b): return a[0] < b[0])
	_start_stepmove()

func _update_walkable():
	var cells = _flood_fill(to_map(active_unit().global_position))
	_astar_walkable = AStarHexagon2D.new(cells)
	_tile_map.clear_layer(1)
	draw(1, cells, 3, Vector2i(0, 0))

func _update_path(event: InputEventMouseMotion):
	if active_unit() and _astar_walkable and not blocked_path:
		var path = _astar_walkable.get_id_path(
			_astar_walkable.mti(to_map(active_unit().global_position)),
			_astar_walkable.mti(to_map(event.position))
		)
		_current_path.clear()
		for cell in path:
			_current_path.append(_astar_walkable.itm(cell))
		_tile_map.clear_layer(2)
		draw(2, _current_path, 1, Vector2i(0, 0))
	
func _move_active_unit():
	if not _current_path:
		return
	acts -= 1
	_tile_map.clear_layer(1)
	active_unit().walk_along(_current_path)
	blocked_path = true
	await active_unit().walk_finished
	blocked_path = false
	_tile_map.clear_layer(2)
	
	_update_stepmove()

func _input(event):
	if is_instance_of(event, InputEventMouseMotion):
		_update_path(_tile_map.make_input_local(event))

	if event.is_action_pressed("move"):
		_move_active_unit()
