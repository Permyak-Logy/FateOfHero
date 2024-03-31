extends Node

class_name TacticalMap
@onready var _tile_map: TileMap = $TileMap

@onready var _astar_board = AStarHexagon2D.new(_tile_map.get_used_cells(0))
@onready var _astar_walkable: AStarHexagon2D

@onready var _current_path = PackedVector2Array()
var _block_input = false
const _ACT_INDEX_MAX = 10000
var unit_queue = []  # [(act_index, unit)]
var units: Array[Unit] = []
var acts: int

var win = null

signal finish

func active_unit() -> Unit:
	return unit_queue[0][1]

func _ready():
	for child in get_children():
		if is_instance_of(child, Unit):
			var unit = child as Unit
			if unit.speed:
				unit_queue.append([_ACT_INDEX_MAX / unit.speed.cur(), unit])
			unit.global_position = to_loc(to_map(unit.global_position))
			units.append(unit)
	unit_queue.sort_custom(func(a, b): return a[0] < b[0])
	_start_stepmove()

func reinit(array: Array[Unit]):
	pass

func get_player_units() -> Array[Unit]:
	return []

func get_enemy_units() -> Array[Unit]:
	return []

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
	print(active_unit(), unit_queue)
	for unit_data in unit_queue:
		if unit_data[1].controlled_player:
			unit_data[1].set_outline_color(Unit.PLAYER_COLOR)
		else:
			unit_data[1].set_outline_color(Unit.ENEMY_COLOR)
	active_unit().set_outline_color(Unit.SELECTED_COLOR)
	acts = active_unit().acts_count
	if active_unit().controlled_player:
		_update_walkable()
		_block_input = false
	else:
		_update_walkable(false)
		active_unit().ai(self)
		await active_unit().ai_act_finished
		_update_stepmove()
	

func _update_stepmove():
	print(active_unit().apply_damage(20))
	if acts != 0 and active_unit().controlled_player:
		_update_walkable()
		_block_input = false
		return
	
	var time = unit_queue[0][0]
	for elem in unit_queue:
		elem[0] -= time
	unit_queue[0][0] += _ACT_INDEX_MAX / active_unit().speed.cur()
	unit_queue.sort_custom(func(a, b): return a[0] < b[0])
	
	var any_player_unit = false
	var any_enemy_unit = false
	for elem in unit_queue:
		var unit: Unit = elem[1]
		if unit.controlled_player:
			any_player_unit = true
		else:
			any_enemy_unit = true
	if any_player_unit != any_enemy_unit:
		return
	_start_stepmove()

func _update_walls():
	_tile_map.clear_layer(3)
	for unit in units:
		if unit == active_unit():
			continue
		_tile_map.set_cell(3, to_map(unit.global_position), 0, Vector2i(2, 0))
		if unit.cells_occupied == 2:
			_tile_map.set_cell(3, to_map(unit.global_position) + Vector2i(1, 0), 0, Vector2i(2, 0))
		
func _update_walkable(draw=true):
	_update_walls()
	var cells = _flood_fill(to_map(active_unit().global_position))
	_astar_walkable = AStarHexagon2D.new(cells)
	_tile_map.clear_layer(1)
	if draw:
		draw(1, cells, 0, Vector2i(3, 0))

func get_path_to_cell(map_coords: Vector2i) -> Array:
	var result = []
	var path = _astar_walkable.get_id_path(
			_astar_walkable.mti(to_map(active_unit().global_position)),
			_astar_walkable.mti(map_coords)
		)
	for cell in path:
		result.append(_astar_walkable.itm(cell))
	return result

func _update_path(event: InputEventMouseMotion):
	if active_unit() and _astar_walkable:
		_current_path = get_path_to_cell(to_map(event.position))
		_tile_map.clear_layer(2)
		draw(2, _current_path, 0, Vector2i(1, 0))
	
func _move_active_unit():
	if not _current_path:
		return
	_block_input = true
	acts -= 1
	_tile_map.clear_layer(1)
	active_unit().walk_along(_current_path)
	await active_unit().walk_finished
	_tile_map.clear_layer(2)
	
	_update_stepmove()

func _input(event):
	if _block_input:
		return
	if is_instance_of(event, InputEventMouseMotion):
		_update_path(_tile_map.make_input_local(event))

	if event.is_action_pressed("move"):
		_move_active_unit()
