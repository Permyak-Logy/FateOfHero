class_name TacticalMap extends Node

@onready var gui: TacticalModeGUI = $TacticalModeGui
@onready var _tile_map: TileMap = $TileMap
@onready var ability_btn = preload("res://GUI/tactical_mode/BtnAbility.tscn")

@onready var _astar_board = AStarHexagon2D.new(_tile_map.get_used_cells(0))
@onready var _astar_walkable: AStarHexagon2D

@onready var _current_path = PackedVector2Array()
var Rock = preload("res://tactical_mode/unit/nature/Rock.tscn")

var _block_input = false
const _ACT_INDEX_MAX = 10000
var unit_queue = []  # [(act_index, unit)]

var acts: int
var _p_units: Array[Unit] = []
var _e_units: Array[Unit] = []
var _n_units: Array[Unit] = []
var units:
	get:
		return _p_units + _e_units + _n_units
const GRID_LAYER = 0
const OVERLAY_PATH_LAYER = 1
const PATH_LAYER = 2
const WALLS_LAYER = 3
const EFFECTS_LAYER = 4
const OVERLAY_ABILITY_LAYER = 5

var escape_ability: EscapeAbility = EscapeAbility.new()

var win = null
var escape = false

var _inited = false
var _entered = false
var inited:
	get:
		return _inited
	set(value):
		_inited = value
		if entered and inited:
			if not is_node_ready():
				await ready
			start_battle()
var entered:
	get:
		return _entered
	set(value):
		_entered = value
		if inited and entered:
			if not is_node_ready():
				await ready
			start_battle()

var __cur_ability: Ability
var cur_ability: Ability :
	get:
		return __cur_ability
	set(value):
		if cur_ability == value:
			return
		gui._on_selected(value)
		__cur_ability = value
var nature_count: int = -1
signal finish(live: Array[PackedScene], death: Array[PackedScene])
enum relation {Equal, Friend, Enemy, Neutral}

func _enter_tree():
	entered = true

func _exit_tree():
	entered = false
	clear()

func _ready():
	""""""
	escape_ability.set_owner(self)
	if is_instance_of($"..", Game):
		return
	_p_units = [
		$GgVamp,
		$Naris,
		$SmolItto
	]
	_e_units = [
		$Vendigo,
		$Skeleton
	]
	_n_units = [
		$Rock,
		$Rock2,
		$Rock3,
		$Rock4,
		$Rock5,
		$Rock6
	]
	inited = true

func start_battle():
	print("*** Start battle ***")
	gen_nature()
	escape = false
	for unit in units:	
		if not unit.is_node_ready():
			await unit.ready
		unit.death.connect(on_kill)
		if unit.speed:
			unit_queue.append([_ACT_INDEX_MAX / unit.speed.cur(), unit])
			unit.init_fight()
	
	unit_queue.sort_custom(func(a, b): return a[0] < b[0])
	_start_stepmove()

func arrange_units():
	if not is_node_ready():
		await ready
	var center = (_astar_board.bottom - _astar_board.top) / 2 + _astar_board.top
	
	if _p_units:
		var step_p = min((_astar_board.bottom - _astar_board.top) / len(_p_units), 6)
		var start_p = center - len(_p_units) * step_p / 2 + step_p / 2
		for i in range(len(_p_units)):
			var y = start_p + i * step_p
			var left_shift = 0
			for cell in _p_units[i].get_occupied_cells():
				left_shift = max(left_shift, (cell - _p_units[i].get_cell())[0])
			move_unit_to(_p_units[i], _astar_board.left + (y + 1) % 2 + left_shift, y)
	
	if _e_units:
		var step_e = min((_astar_board.bottom - _astar_board.top) / len(_e_units), 6)
		var start_e = center - len(_e_units) * step_e / 2 + step_e / 2
		for i in range(len(_e_units)):
			var y = start_e + i * step_e
			
			var right_shift = 0
			for cell in _e_units[i].get_occupied_cells():
				right_shift = max(right_shift, (cell - _e_units[i].get_cell())[0])
			move_unit_to(_e_units[i],  _astar_board.right - right_shift - 1, y)
	

func reinit(player: Array[PackedScene] = [], enemy: Array[PackedScene] = [], count_nature_obj: int=-1):
	clear()
	for p in player:
		_p_units.append(p.instantiate())
	for e in enemy:
		_e_units.append(e.instantiate())
	for unit in _p_units + _e_units:
		add_child(unit)
	arrange_units()
	nature_count = count_nature_obj
	inited = true

func gen_nature(count: int = -1):
	if count < 0:
		count = randi_range(0, 16)
	for i in range(count):
		_update_walls()
		var obj: Node2D = Rock.instantiate()
		_n_units.append(obj)
		add_child(obj)
		while true:
			var pos = Vector2i(
				randi_range(_astar_board.left, _astar_board.right),
				randi_range(_astar_board.bottom, _astar_board.top)
			)
			if not is_occupied(pos):
				obj.global_position = to_loc(pos)
				break

func active_unit() -> Unit:
	return unit_queue[0][1]

func get_relation(unit_a: Unit, unit_b: Unit) -> relation:
	if unit_a == unit_b:
		return relation.Equal
	if is_player(unit_a) and is_player(unit_b):
		return relation.Friend
	if is_enemy(unit_a) and is_enemy(unit_b):
		return relation.Friend
	if is_player(unit_a) and is_enemy(unit_b):
		return relation.Enemy
	if is_enemy(unit_a) and is_player(unit_b):
		return relation.Enemy
	return relation.Neutral

func get_units_with_relation(unit: Unit, r: relation) -> Array[Unit]:
	var result: Array[Unit] = []
	for other in units:
		if get_relation(unit, other) == r:
			result.append(other)
	return result

func clear():
	inited = false
	for child in get_children():
		if is_instance_of(child, Unit):
			remove_child(child)
	win = false
	cur_ability = null
	
	_p_units.clear()
	_e_units.clear()
	_n_units.clear()
	
	unit_queue.clear()
	_block_input = false

func on_kill(unit: Unit):
	for i in range(len(unit_queue)):
		if unit_queue[i][1] == unit:
			unit_queue.pop_at(i)
			print("Poped ", unit)
			break
	print("Killed ", unit)

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
	return cell in _tile_map.get_used_cells(WALLS_LAYER)
	
func _flood_fill() -> Array:
	var cell = active_unit().get_cell()
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

			var blocked = false
			for occ in active_unit().get_occupied_cells():
				var delta = occ - cell
				if is_occupied(next + delta) or not _astar_board.has_cell(next + delta):
					blocked = true
					break
			if blocked:
				continue
			
			if next in array:
				continue
			
			array.append(next)
			stack.append(next)

	return array

func _start_stepmove():
	print("* Start stepmove (unit: ", active_unit().unit_name, ") *")
	cur_ability = null
	for unit_data in unit_queue:
		reset_outline_color(unit_data[1])
	active_unit().set_outline_color(Unit.CUR_COLOR)
	acts = active_unit().acts_count
	(active_unit() as Unit).premove_update()
	for effect in active_unit().get_effects():
		effect.update_on_move()
	
	if active_unit().controlled_player:
		gui.show_abilities(active_unit())
		_update_walkable()
		_block_input = false
	else:
		_update_walkable(false)
		await active_unit().ai(self)
		_update_stepmove()

func level_up():
	pass 

func _update_stepmove():
	print("* Update stepmove *")
	cur_ability = null
	_tile_map.set_layer_enabled(OVERLAY_PATH_LAYER, true)
	
	var killed_player_units = _p_units.all(func (x): return x.is_death())
	var killed_enemy_units = _e_units.all(func (x): return x.is_death())
	
	if killed_player_units != killed_enemy_units or escape:
		_tile_map.clear_layer(OVERLAY_PATH_LAYER)
		_tile_map.clear_layer(PATH_LAYER)
		win = not escape
		_block_input = true
		print("*** FINISH! ***")
		level_up()
		var packed_live: Array[PackedScene] = []
		var packed_death: Array[PackedScene] = []
		for unit in _p_units:
			
			var pack = PackedScene.new()
			pack.pack(unit)
			if unit.is_death():
				packed_death.append(pack)
			else:
				packed_live.append(pack)
		finish.emit(packed_live, packed_death)
		return
	
	if acts != 0 and active_unit().controlled_player:
		_update_walkable()
		_block_input = false
		return
		
	print("* End stepmove *")
	
	var time = unit_queue[0][0]
	for elem in unit_queue:
		elem[0] -= time
	unit_queue[0][0] += _ACT_INDEX_MAX / active_unit().speed.cur()
	unit_queue.sort_custom(func(a, b): return a[0] < b[0])
	
	_start_stepmove()

func _update_walls():
	_tile_map.clear_layer(WALLS_LAYER)
	for unit in units:
		if not unit.is_node_ready():
			await unit.ready
		if unit.is_death():
			continue
		for cell in unit.get_occupied_cells():
			_tile_map.set_cell(3, cell, 0, Vector2i(2, 0))
		
func _update_walkable(show=true):
	_update_walls()
	var cells = _flood_fill()
	_astar_walkable = AStarHexagon2D.new(cells)
	_tile_map.clear_layer(OVERLAY_PATH_LAYER)
	if show:
		draw(OVERLAY_PATH_LAYER, cells, 0, Vector2i(3, 0))
		_select_path_to(to_map(_tile_map.get_local_mouse_position()))

func get_path_to_cell(map_coords: Vector2i) -> Array:
	var result = []
	if not _astar_walkable.has_cell(map_coords):
		return []
	var path = _astar_walkable.get_id_path(
			_astar_walkable.mti(active_unit().get_cell()),
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
	print("=> ", active_unit().unit_name, " передвигается")
	_block_input = true
	acts -= 1
	_tile_map.clear_layer(OVERLAY_PATH_LAYER)
	gui.clear_abilities()
	await active_unit().play("walk", _current_path)
	_tile_map.clear_layer(PATH_LAYER)
	
	_update_stepmove()

func _input(event):
	if _block_input:
		return
	if is_instance_of(event, InputEventMouseMotion):
		var cell: Vector2i = to_map(_tile_map.make_input_local(event).position)
		if not cur_ability:
			_select_path_to(cell)
		elif is_instance_of(cur_ability, AoEAbility) and (cur_ability as AoEAbility).cell != cell:
			_tile_map.clear_layer(OVERLAY_ABILITY_LAYER)
			if (cur_ability as AoEAbility).can_select_cell(cell):
				(cur_ability as AoEAbility).select_cell(cell)
				draw_aoe_overlay()
			else:
				(cur_ability as AoEAbility).unselect_cell()
				
	if event.is_pressed():
		return await _key_press_event(event)

func draw_aoe_overlay():
	draw(
		OVERLAY_ABILITY_LAYER, 
		(cur_ability as AoEAbility).about_cells, 
		0, 
		(cur_ability as AoEAbility).overlay_atlas_coords
	)

func _key_press_event(event):
	if event.as_text().is_valid_int():
		var i = (event.as_text().to_int() + 9) % 10
		var abilities = active_unit().get_abilities()
		if len(abilities) > i and abilities[i].can_use():
			_prepare_ability(abilities[i])
	elif cur_ability:
		if event.is_action_pressed("cancel_ability"):
			_cancel_ability()
		if event.is_action_pressed("next_ability"):
			var abilities = active_unit().get_abilities()
			_prepare_ability(abilities[(abilities.find(cur_ability) + 1) % len(abilities)])
		if event.is_action_pressed("prev_ability"):
			var abilities = active_unit().get_abilities()
			_prepare_ability(abilities[(abilities.find(cur_ability) - 1 + len(abilities)) % len(abilities)])
		if is_instance_of(cur_ability, DirectedAbility):
			if event.is_action_pressed("apply_ability"):
				_apply_ability()
			if event.is_action_pressed("prev_target"):
				cur_ability.tab_prev()
			if event.is_action_pressed("next_target"):
				cur_ability.tab_next()
		if is_instance_of(cur_ability, AoEAbility):
			if event.is_action_pressed("apply_aoe_ability"):
				_apply_ability(to_map(_tile_map.make_input_local(event).position))
	elif event.is_action_pressed("move"):
		_move_active_unit()
	elif event.is_action_pressed("escape_fight"):
		_prepare_ability(escape_ability)

func _prepare_ability(ability: Ability):
	print("-> Selected ", ability)
	_cancel_ability()
	_tile_map.clear_layer(OVERLAY_ABILITY_LAYER)
	_tile_map.set_layer_enabled(OVERLAY_PATH_LAYER, true)
	cur_ability = ability
	cur_ability.clear()
	if is_instance_of(cur_ability, DirectedAbility):
		cur_ability.find_all_selectable_tab_targets()
		cur_ability.auto_select()
	if is_instance_of(cur_ability, AoEAbility):
		var cell: Vector2i = to_map(_tile_map.get_local_mouse_position())
		if (cur_ability as AoEAbility).can_select_cell(cell):
			(cur_ability as AoEAbility).select_cell(cell)
			draw_aoe_overlay()
	_tile_map.set_layer_enabled(OVERLAY_PATH_LAYER, false)
	_tile_map.clear_layer(PATH_LAYER)

func _cancel_ability():
	if not cur_ability:
		return
	cur_ability.clear()
	_tile_map.clear_layer(OVERLAY_ABILITY_LAYER)
	_tile_map.set_layer_enabled(OVERLAY_PATH_LAYER, true)
	cur_ability = null

func _apply_ability(cell=Vector2i(0, 0)):
	if is_instance_of(cur_ability, DirectedAbility) and cell:
		if cur_ability.can_select_cell():
			cur_ability.select_cell(cell)
	
	if cur_ability.can_apply():
		_block_input = true
		_tile_map.clear_layer(OVERLAY_ABILITY_LAYER)
		gui.clear_abilities()
		await cur_ability.apply()
		cur_ability.after_apply()
		_update_stepmove()

func distance_between_cells(a: Vector2i, b: Vector2i) -> int:
	var path = _astar_board.get_id_path(_astar_board.mti(a), _astar_board.mti(b))
	return len(path) - 1

func is_player(unit: Unit):
	return unit in _p_units

func is_enemy(unit: Unit):
	return unit in _e_units

func reset_outline_color(unit: Unit):
	if cur_ability and unit in cur_ability.selected:
		unit.set_outline_color(Unit.SELECTED_COLOR)
	elif unit.is_death():
		unit.set_outline_color(Unit.DEFAULT_COLOR)
	elif active_unit() == unit:
		unit.set_outline_color(Unit.CUR_COLOR)
	elif is_player(unit):
		unit.set_outline_color(Unit.PLAYER_COLOR)
	elif is_enemy(unit):
		unit.set_outline_color(Unit.ENEMY_COLOR)
	else:
		unit.set_outline_color(Unit.DEFAULT_COLOR)
