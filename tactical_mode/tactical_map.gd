class_name TacticalMap extends Node

@onready var gui: TacticalModeGUI = $TacticalModeGui
@onready var _tile_map: TileMap = $TileMap
@onready var _astar_board = AStarHexagon2D.new(_tile_map.get_used_cells(0))
@onready var _astar_walkable: AStarHexagon2D

@onready var _current_path = PackedVector2Array()
var Rock = preload("res://tactical_mode/nature/Rock.tscn")
var ability_btn = preload("res://GUI/tactical_mode/BtnAbility.tscn")
var level_up_gui = preload("res://GUI/level_up/level_up_gui.tscn")

var _block_input = false  # Блокировка пользовательского ввода
const _ACT_INDEX_MAX = 10000  # Магическая константа для порядка ходов
var unit_queue = []  # [(act_index, unit)]

var active_unit: Unit:  # Текущий 
	get:
		if unit_queue:
			return unit_queue[0][1]
		return null

var acts: int  # Текущее кол-во действий
var _p_units: Array[Unit] = []  # Список юнитов игрока
var _e_units: Array[Unit] = []  # Список юнитов оппонента
var units:  # property список всех юнитов
	get:
		return _p_units + _e_units

var actors:
	get:
		var res = []
		for child in get_children():
			if is_instance_of(child, Actor):
				res.append(child)
		return res
const GRID_LAYER = 0  # Слой сетки
const OVERLAY_PATH_LAYER = 1  # Слой оверлея для перемещения
const PATH_LAYER = 2  # Слой пути
const WALLS_LAYER = 3  # Слой стен
const OVERLAY_ABILITY_LAYER = 4  # Слой оверлея для способностей

var escape_ability: EscapeAbility = load("res://tactical_mode/EscapeAbility.tres")  # Способность побега

var win: bool = false  # True если мы победили и закончили бой, иначе false 
var escape = false  # True если был активирован побег
var running = false  # Запущен ли бой

var inited = true:  # Проинициализирована ли карта
	set(value):
		inited = value
		if is_inside_tree() and inited:
			if not is_node_ready():
				await ready
			start_battle()

var cur_ability: Ability = null:  # Текущая выбранная способность
	set(value):
		if cur_ability == value:
			return
		gui._on_selected(value)
		cur_ability = value

var nature_count: int = -1  # Кол-во природных actor выступающих в роли стен 

# Вызывается после завершения боя, возвращает списки живых и мёртвых персонажей
signal finish(live: Array[PackedScene], death: Array[PackedScene])

# Отношения между разными юнитами
enum relation {Equal, Friend, Enemy, Neutral}

func _enter_tree():
	if inited:
		if not is_node_ready():
			await ready
		start_battle()

func _exit_tree():
	clear()

func _init():
	escape_ability.set_owner(self)

func _ready():
	if is_instance_of($"..", Game):
		return
	_p_units = [$Naris,$Berserk,$SmolItto,$Vamp
	]
	_e_units = [
		$Vendigo,$Lugozavr,$Vedmachok
	]
	inited = true

func start_battle():
	"""
	Запускает бой, добавляет юнитов во очередь ходов
	"""
	if running:
		return
	gui.tactical_info.clear()	
	running = true
	write_info("*** Бой начинается ***")
	align_actors()
	escape = false
	for unit in units:	
		if not unit.is_node_ready():
			await unit.ready
		if unit.speed:
			add_to_unit_queue(unit)
			unit.prepare_fight()
	
	unit_queue.sort_custom(func(a, b): return a[0] < b[0])
	_start_stepmove()

func align_actors():
	"""
	Выравнивает всех дочерних Actor на карте
	"""
	
	for child in get_children():
		if is_instance_of(child, Actor):
			child.global_position = to_loc(child.get_cell())

func arrange_units():
	"""
	Выполняет расстановку юнитов из _p_units и _e_units
	"""
	
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
			move_unit_to(_p_units[i], Vector2i(_astar_board.left + (y + 1) % 2 + left_shift, y))
	
	if _e_units:
		var step_e = min((_astar_board.bottom - _astar_board.top) / len(_e_units), 6)
		var start_e = center - len(_e_units) * step_e / 2 + step_e / 2
		for i in range(len(_e_units)):
			var y = start_e + i * step_e
			
			var right_shift = 0
			for cell in _e_units[i].get_occupied_cells():
				right_shift = max(right_shift, (cell - _e_units[i].get_cell())[0])
			move_unit_to(_e_units[i],  Vector2i(_astar_board.right - right_shift - 1, y))
	

func reinit(player: Array[PackedScene] = [], enemy: Array[PackedScene] = [], count_nature_obj: int=-1):
	"""
	Сбрасывает прошлые данные и загружает новые, подготавливает бой,
	запускает бой, если TacticalMap в "SceneTree"
	"""
	
	clear()
	
	for p in player:
		_p_units.append(spawn(p, Vector2i(0, 0)))
	for e in enemy:
		_e_units.append(spawn(e, Vector2i(0, 0)))
	arrange_units()
	if count_nature_obj < 0:
		nature_count = randi_range(0, 16)
	else:
		nature_count = count_nature_obj
	gen_nature()
	inited = true

func gen_nature():
	"""
	Генерирует неуправляемые природные объекты/стены
	"""
	
	for i in range(nature_count):
		await _update_walls()
		while true:
			var pos = Vector2i(
				randi_range(_astar_board.left, _astar_board.right),
				randi_range(_astar_board.bottom, _astar_board.top)
			)
			if not is_occupied(pos):
				spawn(Rock, pos)
				break


func get_relation(unit_a: Unit, unit_b: Unit) -> relation:
	"""
	Вернуть relation между юнитами
	"""
	
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
	"""
	Возращает список всех юнитов которые имеют отношение 'r' к 'unit'
	"""
	
	var result: Array[Unit] = []
	for other in units:
		if get_relation(unit, other) == r:
			result.append(other)
	return result

func clear():
	"""
	Очистка всех Actor, сброс переменных
	"""
	
	inited = false
	for child in get_children():
		if is_instance_of(child, Actor):
			remove_child(child)
	win = false
	cur_ability = null
	running = false
	
	_p_units.clear()
	_e_units.clear()
	
	unit_queue.clear()
	_block_input = false

func on_kill(unit: Unit):
	"""
	Вызывается при смерти любого юнита
	"""
	
	for i in range(len(unit_queue)):
		if unit_queue[i][1] == unit:
			unit_queue.pop_at(i)
			break
	reset_outline_color(unit)
	write_info("-> " + unit.unit_name + " убит")

func move_unit_to(actor: Actor, cell: Vector2i):
	"""
	Передвигает юнита на указанную клетку на tilemap
	"""
	
	actor.global_position = to_loc(cell)

func get_player_units() -> Array[Unit]:
	"""
	возвращает список юнитов игрока
	"""
	
	return _p_units

func get_enemy_units() -> Array[Unit]:
	"""
	Возвращает список юнитов оппонента
	"""
	
	return _e_units

func draw(layer: int, array: Array, source_id: int = -1, 
atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0):
	"""
	Отрисовывает тайлы сразу на массиве с одинаковыми параметрами
	эквивалентно многокрантному использованию TileMap.set_cell
	"""
	
	for coords in array:
		_tile_map.set_cell(
			layer, coords, source_id,atlas_coords, alternative_tile)

func to_map(cell: Vector2) -> Vector2i:
	"""
	Переводит глобальные координаты в координаты клеток
	"""
	
	if _tile_map:
		return _tile_map.local_to_map(cell)
	return Vector2i(0, 0)

func to_loc(cell: Vector2i) -> Vector2:
	"""
	Переводит координаты клеток в глобальные координаты
	"""
	
	if _tile_map:
		return _tile_map.map_to_local(cell)
	return Vector2(0, 0)

func is_occupied(cell: Vector2i) -> bool:
	"""
	Блокируется ли клетка каким-то объектом
	"""
	
	return cell in _tile_map.get_used_cells(WALLS_LAYER)
	
func walkable_fill(max_distance: float=1000) -> Array:
	"""
	Возвращает список клеток доступных для перемещения
	"""
	
	var cell = active_unit.get_cell()
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
			for occ in active_unit.get_occupied_cells():
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
	"""
	Вызывается перед каждым ходом юнита (но не действием)
	"""
	
	# await get_tree().create_timer(0.25).timeout
	write_info("* Ходит: " + active_unit.unit_name + " *")
	
	cur_ability = null
	for unit_data in unit_queue:
		reset_outline_color(unit_data[1])
	active_unit.set_outline_color(Unit.CUR_COLOR)
	acts = active_unit.acts_count
	(active_unit as Unit).premove_update()
	
	if acts == 0:
		_update_stepmove()
		return
	
	if active_unit.controlled_player:
		gui.show_abilities(active_unit)
		_update_walkable()
		_block_input = false
	else:
		_update_walkable(true)
		active_unit.ai(self)

func _update_stepmove():
	"""
	Вызывается перед каждым действием юнита
	"""
	
	cur_ability = null
	_tile_map.set_layer_enabled(OVERLAY_PATH_LAYER, true)
	
	var killed_player_units = _p_units.all(func (x): return x.is_death())
	var killed_enemy_units = _e_units.all(func (x): return x.is_death())
	
	if killed_player_units != killed_enemy_units or escape or not running:
		_finalize_fight(killed_enemy_units and not escape)
		return
	
	if acts != 0:
		write_info("* Ход продолжается *")
		if active_unit.controlled_player:
			_update_walkable()
			_block_input = false
		else:
			_update_walkable(false)
			active_unit.ai(self)
		return
	
	var time = unit_queue[0][0]
	for elem in unit_queue:
		elem[0] -= time
	unit_queue[0][0] += _ACT_INDEX_MAX / active_unit.speed.cur()
	unit_queue.sort_custom(func(a, b): return a[0] < b[0])
	_start_stepmove()

func _finalize_fight(_win=false):
	_tile_map.clear_layer(OVERLAY_PATH_LAYER)
	_tile_map.clear_layer(PATH_LAYER)
	win = _win
	_block_input = true
	write_info("*** Бой завершён ***")
	running = false
	for player in get_player_units():
		if player.is_death():
			continue
		var expirience = 0
		for enemy in get_enemy_units():
			if enemy.is_death():
				expirience += int(enemy.health.get_max() / 10)
		player.expirience.add_exp(expirience)
		if player.expirience.can_level_up():
			var lug: LevelUpGUI = level_up_gui.instantiate()
			lug.unit = player
			lug.pts = player.expirience.ups
			gui.add_child(lug)
			await lug.done
			player.expirience.ups = 0
			gui.remove_child(lug)
		while player.get_effects():
			player.remove_effect(player.get_effects()[0])

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

func _update_walls():
	"""
	Обновляет слой стен
	"""
	
	if not is_node_ready():
		await ready
	_tile_map.clear_layer(WALLS_LAYER)

	for child in get_children():
		if is_instance_of(child, Unit):
			if not child.is_node_ready():
				await child.ready
			if child.is_death():
				continue
		if is_instance_of(child, Actor):
			for cell in child.get_occupied_cells():
				_tile_map.set_cell(3, cell, 0, Vector2i(2, 0))

func _update_walkable(show=true):
	"""
	Обнавляет слой оверлея перемещения
	"""
	
	_update_walls()
	var cells = walkable_fill(active_unit.get_move_distance())
	_astar_walkable = AStarHexagon2D.new(cells)
	_tile_map.clear_layer(OVERLAY_PATH_LAYER)
	if show:
		draw(OVERLAY_PATH_LAYER, cells, 0, Vector2i(3, 0))
		select_path_to(to_map(_tile_map.get_local_mouse_position()))

func get_path_to_cell(map_coords: Vector2i) -> Array[Vector2i]:
	"""
	Возвращает путь из списка клеток на основе оверлея перемещения
	"""
	
	var result: Array[Vector2i] = []
	if not _astar_walkable.has_cell(map_coords):
		return []
	var path = _astar_walkable.get_id_path(
			_astar_walkable.mti(active_unit.get_cell()),
			_astar_walkable.mti(map_coords)
		)
	for cell in path:
		result.append(_astar_walkable.itm(cell))
	return result

func select_path_to(cell: Vector2i):
	"""
	Отрисовывает путь до клетки в оверлее
	"""
	
	if active_unit and _astar_walkable:
		_current_path = get_path_to_cell(cell)
		_tile_map.clear_layer(PATH_LAYER)
		draw(PATH_LAYER, _current_path, 0, Vector2i(1, 0))

func can_move_to(cell: Vector2i):
	return _astar_walkable.has_cell(cell)

func _move_active_unit():
	"""
	Запускает передвижение юнита, завершает действие
	"""
	
	if not _current_path:
		return
	write_info("=> " + active_unit.unit_name + " передвигается")
	_block_input = true
	
	_tile_map.clear_layer(OVERLAY_PATH_LAYER)
	gui.clear_abilities()
	if len(_current_path) > 1:
		acts -= 1
		await active_unit.play("walk", _current_path)
	else:
		acts = 0
	_tile_map.clear_layer(PATH_LAYER)
	
	_update_stepmove()

func _input(event):
	if _block_input:
		return
	if is_instance_of(event, InputEventMouseMotion):
		var cell: Vector2i = to_map(_tile_map.make_input_local(event).position)
		if not cur_ability:
			select_path_to(cell)
		elif is_instance_of(cur_ability, AoEAbility):
			if (cur_ability as AoEAbility).cell == cell:
				return
			if (cur_ability as AoEAbility).only_auto_select:
				return
			_tile_map.clear_layer(OVERLAY_ABILITY_LAYER)
			if (cur_ability as AoEAbility).can_select_cell(cell):
				(cur_ability as AoEAbility).select_cell(cell)
				draw_ability_overlay()
			else:
				(cur_ability as AoEAbility).unselect_cell()
				
	if event.is_pressed():
		return await _key_press_event(event)

func draw_ability_overlay():
	"""
	Отрисовка зоны действия AoE способности
	"""
	
	var cells = cur_ability.fill_overlay()
	if cells:
		draw(
			OVERLAY_ABILITY_LAYER, 
			cells, 
			0, 
			cur_ability.overlay_atlas_coords
		)

func _key_press_event(event):
	"""
	Событие нажатий клавиатуры
	"""
	
	if event.as_text().is_valid_int():
		var i = (event.as_text().to_int() + 9) % 10
		var abilities = active_unit.get_abilities()
		if len(abilities) > i and abilities[i].can_use():
			_prepare_ability(abilities[i])
	elif cur_ability:
		if event.is_action_pressed("cancel_ability"):
			_cancel_ability()
		if event.is_action_pressed("next_ability"):
			var abilities = active_unit.get_abilities()
			_prepare_ability(abilities[(abilities.find(cur_ability) + 1) % len(abilities)])
		if event.is_action_pressed("prev_ability"):
			var abilities = active_unit.get_abilities()
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
	"""
	Подготавливает к использованию способность
	"""
	
	write_info("-> Выбрана способность '" + ability.name + "'")
	_cancel_ability()
	
	_tile_map.set_layer_enabled(OVERLAY_PATH_LAYER, true)
	cur_ability = ability
	cur_ability.clear()
	if is_instance_of(cur_ability, DirectedAbility):
		cur_ability.find_all_selectable_tab_targets()
		cur_ability.auto_select()
	if is_instance_of(cur_ability, AoEAbility):
		var cell: Vector2i
		if cur_ability.only_auto_select:
			cell = cur_ability.default_cell()
		else:
			cell = to_map(_tile_map.get_local_mouse_position())
		if (cur_ability as AoEAbility).can_select_cell(cell):
			(cur_ability as AoEAbility).select_cell(cell)
			draw_ability_overlay()
	_tile_map.clear_layer(OVERLAY_ABILITY_LAYER)
	draw_ability_overlay()
	_tile_map.set_layer_enabled(OVERLAY_PATH_LAYER, false)
	_tile_map.clear_layer(PATH_LAYER)

func _cancel_ability():
	"""
	Отменяет использование выбранной способности
	"""
	
	if not cur_ability:
		return
	cur_ability.clear()
	_tile_map.clear_layer(OVERLAY_ABILITY_LAYER)
	_tile_map.set_layer_enabled(OVERLAY_PATH_LAYER, true)
	cur_ability = null

func _apply_ability(cell=Vector2i(0, 0)):
	"""
	Применяет действие выбранной способности, завершает действие
	"""
	if is_instance_of(cur_ability, AoEAbility):
		if cur_ability.only_auto_select:
			cell = cur_ability.default_cell()
		if cell and cur_ability.can_select_cell(cell):
			cur_ability.select_cell(cell)
	
	if cur_ability.can_apply():
		_block_input = true
		_tile_map.clear_layer(OVERLAY_ABILITY_LAYER)
		gui.clear_abilities()
		await cur_ability.apply()
		cur_ability.after_apply()
		_update_stepmove()

func distance_between_cells(a: Vector2i, b: Vector2i) -> int:
	"""
	Расстояние между клетками на поле без учёта стен
	"""
	
	if not _astar_board.has_cell(a) or not _astar_board.has_cell(b):
		return 0
	var path = _astar_board.get_id_path(_astar_board.mti(a), _astar_board.mti(b))
	return len(path) - 1

func is_player(unit: Unit) -> bool:
	return unit in _p_units

func is_enemy(unit: Unit) -> bool:
	return unit in _e_units

func reset_outline_color(unit: Unit):
	"""
	Сбрасывает цвет обводки на основе текущего состояния юнита
	"""
	
	if cur_ability and is_instance_of(cur_ability, DirectedAbility) and unit in cur_ability.selected:
		unit.set_outline_color(Unit.SELECTED_COLOR)
	elif unit.is_death():
		unit.set_outline_color(Unit.DEFAULT_COLOR)
	elif active_unit == unit:
		unit.set_outline_color(Unit.CUR_COLOR)
	elif is_player(unit):
		unit.set_outline_color(Unit.PLAYER_COLOR)
	elif is_enemy(unit):
		unit.set_outline_color(Unit.ENEMY_COLOR)
	else:
		unit.set_outline_color(Unit.DEFAULT_COLOR)

func spawn(actor_ps: PackedScene, cell: Vector2i, _instigator: Unit = null) -> Actor:
	"""
	Спавнит Actor в позиции cell
	"""
	
	var actor: Actor = actor_ps.instantiate()
	add_child(actor)
	move_unit_to(actor, cell)
	
	if is_instance_of(actor, Unit):
		var unit = actor as Unit
		if is_player(_instigator):
			_p_units.append(unit)
		if is_enemy(_instigator):
			_e_units.append(unit)
		if running:
			unit.prepare_fight()
			reset_outline_color(unit)
			write_info("=> " + unit.unit_name + " появляется!")
	return actor

func add_to_unit_queue(unit: Unit, in_start=false):
	if in_start:
		unit_queue.insert(int(len(unit_queue) > 0), [unit_queue[0][0], unit])
	else:
		unit_queue.append([_ACT_INDEX_MAX / unit.speed.cur(), unit])

func write_info(text: String):
	gui.tactical_info.write(text)
