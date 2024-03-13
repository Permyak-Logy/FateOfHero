extends Node

class_name TacticalMap
@onready var _tile_map: TileMap = $TileMap

@onready var _astar_board = AStarHexagon2D.new(_tile_map.get_used_cells(0))
@onready var _astar_walkable: AStarHexagon2D

@onready var _active_unit: Unit = $Naris
@onready var _current_path = PackedVector2Array()
var blocked_path = false

func _ready():
	_active_unit = $Naris
	_update_walkable()

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
	
func _flood_fill(cell: Vector2i, max_distance: int = 6, cells: int = 1) -> Array:
	var array := [cell]
	var stack := [cell, 0]
	var distance = 0
	# breakpoint
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
			if cells == 2 and is_occupied(next + Vector2i(1, 0)):
				continue
			if next in array:
				continue
	
			array.append(next)
			stack.append(next)

	return array

func _update_walkable():
	var cells = _flood_fill(to_map(_active_unit.global_position))
	_astar_walkable = AStarHexagon2D.new(cells)
	_tile_map.clear_layer(1)
	draw(1, cells, 3, Vector2i(0, 0))

func _update_path(event: InputEventMouseMotion):
	if _active_unit and _astar_walkable and not blocked_path:
		var path = _astar_walkable.get_id_path(
			_astar_walkable.mti(to_map(_active_unit.global_position)),
			_astar_walkable.mti(to_map(event.global_position))
		)
		_current_path.clear()
		for cell in path:
			_current_path.append(_astar_walkable.itm(cell))
		_tile_map.clear_layer(2)
		draw(2, _current_path, 1, Vector2i(0, 0))
	
func _move_active_unit():
	if not _current_path:
		return
	# warning-ignore:return_value_discarded
	# _units.erase(_active_unit.cell)
	# _units[new_cell] = _active_unit
	_tile_map.clear_layer(1)
	_active_unit.walk_along(_current_path)
	blocked_path = true
	await _active_unit.walk_finished
	blocked_path = false
	print("Go 2!")
	_update_walkable()
	# _clear_active_unit()

func _input(event):
	if is_instance_of(event, InputEventMouseMotion):
		_update_path(event)

	if event.is_action_pressed("move"):
		_move_active_unit()
