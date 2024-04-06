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
var _p_units: Array[Unit] = []
var _e_units: Array[Unit] = []

const GRID_LAYER = 0
const OVERLAY_LAYER = 1
const PATH_LAYER = 2
const WALLS_LAYER = 3

var win = null
var cur_ability: Ability = null

signal finish

func active_unit() -> Unit:
	return unit_queue[0][1]

func clear():
	for child in get_children():
		if is_instance_of(child, Unit):
			remove_child(child)
	win = false
	cur_ability = null
	units.clear()
	unit_queue.clear()
	_block_input = false

func on_kill(unit: Unit):
	for i in range(len(unit_queue)):
		if unit_queue[i][1] == unit:
			unit_queue.pop_at(i)
			break
	unit.set_outline_color(Unit.DEFAULT_COLOR)
	print("Killed ", unit)

func reinit(player: Array[PackedScene] = [], enemy: Array[PackedScene] = []):
	if not is_node_ready():
		await ready
	clear()
	_p_units.clear()
	_e_units.clear()
	for p in player:
		_p_units.append(p.instantiate())
		
	for e in enemy:
		_e_units.append(e.instantiate())
		
	for unit in _p_units + _e_units:
		add_child(unit)
		print(unit.is_node_ready(), unit)
		if unit.speed:
			unit_queue.append([_ACT_INDEX_MAX / unit.speed.cur(), unit])
		unit.death.connect(on_kill)
		units.append(unit)
		unit.init_fight()
	
	var center = (_astar_board.bottom - _astar_board.top) / 2 + _astar_board.top
	
	if _p_units:
		var step_p = min((_astar_board.bottom - _astar_board.top) / len(_p_units), 6)
		var start_p = center - len(_p_units) * step_p / 2 + step_p / 2
		for i in range(len(_p_units)):
			var y = start_p + i * step_p
			move_unit_to(_p_units[i], _astar_board.left + (y + 1) % 2, y)
	
	if _e_units:
		var step_e = min((_astar_board.bottom - _astar_board.top) / len(_e_units), 6)
		var start_e = center - len(_e_units) * step_e / 2 + step_e / 2
		for i in range(len(_e_units)):
			var y = start_e + i * step_e
			move_unit_to(_e_units[i],  _astar_board.right - _e_units[i].cells_occupied, y)
	
	unit_queue.sort_custom(func(a, b): return a[0] < b[0])
	_start_stepmove()

func move_unit_to(unit: Unit, x: int, y: int):
	unit.global_position = to_loc(Vector2i(x, y))

func get_player_units() -> Array[Unit]:
	return _p_units

func get_enemy_units() -> Array[Unit]:
	return _e_units

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
	cur_ability = null
	for unit_data in unit_queue:
		if unit_data[1].controlled_player:
			unit_data[1].set_outline_color(Unit.PLAYER_COLOR)
		else:
			unit_data[1].set_outline_color(Unit.ENEMY_COLOR)
	active_unit().set_outline_color(Unit.CUR_COLOR)
	acts = active_unit().acts_count
	(active_unit() as Unit).premove_update()
	if active_unit().controlled_player:
		_update_walkable()
		_block_input = false
	else:
		_update_walkable(false)
		await active_unit().ai(self)
		_update_stepmove()
	

func _update_stepmove():
	cur_ability = null
	_tile_map.set_layer_enabled(OVERLAY_LAYER, true)
	
	var killed_player_units = _p_units.all(func (x): return x.is_death())
	var killed_enemy_units = _e_units.all(func (x): return x.is_death())
	
	if killed_player_units != killed_enemy_units:
		_tile_map.clear_layer(OVERLAY_LAYER)
		_tile_map.clear_layer(PATH_LAYER)
		win = true
		# _block_input = true
		print("*** FINISH! ***")
		finish.emit()
		return
	
	if acts != 0 and active_unit().controlled_player:
		_update_walkable()
		_block_input = false
		return
	
	var time = unit_queue[0][0]
	for elem in unit_queue:
		elem[0] -= time
	unit_queue[0][0] += _ACT_INDEX_MAX / active_unit().speed.cur()
	unit_queue.sort_custom(func(a, b): return a[0] < b[0])
	
	_start_stepmove()

func _update_walls():
	_tile_map.clear_layer(WALLS_LAYER)
	for unit in units:
		if unit == active_unit():
			continue
		if unit.is_death():
			continue
		_tile_map.set_cell(3, to_map(unit.global_position), 0, Vector2i(2, 0))
		if unit.cells_occupied == 2:
			_tile_map.set_cell(3, to_map(unit.global_position) + Vector2i(1, 0), 0, Vector2i(2, 0))
		
func _update_walkable(show=true):
	_update_walls()
	var cells = _flood_fill(to_map(active_unit().global_position))
	_astar_walkable = AStarHexagon2D.new(cells)
	_tile_map.clear_layer(OVERLAY_LAYER)
	if show:
		draw(OVERLAY_LAYER, cells, 0, Vector2i(3, 0))
		_select_path_to(to_map(_tile_map.get_local_mouse_position()))

func get_path_to_cell(map_coords: Vector2i) -> Array:
	var result = []
	if not _astar_walkable.has_cell(map_coords):
		return []
	var path = _astar_walkable.get_id_path(
			_astar_walkable.mti(to_map(active_unit().global_position)),
			_astar_walkable.mti(map_coords)
		)
	for cell in path:
		result.append(_astar_walkable.itm(cell))
	return result

func _select_path_to(cell: Vector2i):
	if active_unit() and _astar_walkable:
		_current_path = get_path_to_cell(cell)
		_tile_map.clear_layer(PATH_LAYER)
		draw(PATH_LAYER, _current_path, 0, Vector2i(1, 0))
	
func _move_active_unit():
	if not _current_path:
		return
	_block_input = true
	acts -= 1
	_tile_map.clear_layer(OVERLAY_LAYER)
	await active_unit().play("walk", _current_path)
	_tile_map.clear_layer(PATH_LAYER)
	
	_update_stepmove()

func _input(event):
	if _block_input:
		return
	if is_instance_of(event, InputEventMouseMotion):
		if not cur_ability:
			_select_path_to(to_map(_tile_map.make_input_local(event).position))
	
	if event.is_pressed():
		return await _key_press_event(event)
		
func _key_press_event(event):
	if cur_ability:
		if event.is_action_pressed("apply_ability"):
			if cur_ability.can_apply():
				_block_input = true
				await cur_ability.apply()
				cur_ability.after_apply()
				_update_stepmove()
		if event.is_action_pressed("cancel_ability"):
			cur_ability.clear()
			_tile_map.set_layer_enabled(OVERLAY_LAYER, true)
			cur_ability = null
	else:
		if event.is_action_pressed("move"):
			_move_active_unit()
		if event.as_text().is_valid_int():
			var i = (event.as_text().to_int() + 9) % 10
			var abilities = active_unit().get_abilities()
			if len(abilities) > i and abilities[i].can_use():
				cur_ability = abilities[i]
				cur_ability.auto_select()
				_tile_map.set_layer_enabled(OVERLAY_LAYER, false)
				_tile_map.clear_layer(PATH_LAYER)

func distance_between_cells(a: Vector2i, b: Vector2i) -> int:
	var path = _astar_board.get_id_path(_astar_board.mti(a), _astar_board.mti(b))
	return len(path)

func is_player(unit: Unit):
	return unit in _p_units

func is_enemy(unit: Unit):
	return unit in _e_units

func reset_outline_color(unit: Unit):
	if active_unit() == unit:
		unit.set_outline_color(Unit.CUR_COLOR)
	elif is_player(unit):
		unit.set_outline_color(Unit.PLAYER_COLOR)
	elif is_enemy(unit):
		unit.set_outline_color(Unit.ENEMY_COLOR)
	elif cur_ability and unit in cur_ability.selected:
		unit.set_outline_color(Unit.SELECTED_COLOR)
	else:
		unit.set_outline_color(Unit.DEFAULT_COLOR)
