extends Node
class_name TacticalMap

@onready var _tile_map: TileMap = $TileMap
@onready var _tile_rect: Rect2i = _tile_map.get_used_rect()

const _MOD_CELL_ID = 1000 
var _astar = AStar2D.new()

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

@onready var _active_unit = $CharacterBody2D

func _ready():
	_reinitialize()
	var array = _flood_fill(to_map($CharacterBody2D.global_position))
	print(array)
	draw(1, array, 1, Vector2i(0, 0))

func draw(layer: int, array: Array, source_id: int = -1, 
atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0):
	for coords in array:
		_tile_map.set_cell(
			layer, coords, source_id,atlas_coords, alternative_tile)

func to_map(cell: Vector2) -> Vector2i:
	return _tile_map.local_to_map(cell)
	
func to_loc(cell: Vector2i) -> Vector2:
	return _tile_map.map_to_local(cell)

func mti(cell: Vector2i) -> int:
	return cell[0] * _MOD_CELL_ID + cell[1] % _MOD_CELL_ID

func itm(cell: int) -> Vector2i:
	return _astar.get_point_position(cell) as Vector2i

func _reinitialize() -> void:
	_astar.clear()
	var cells = _tile_map.get_used_cells(0)
	for cell in cells:
		_astar.add_point(mti(cell), cell)
	for cell in cells:
		var cell_id = mti(cell) 
		for direction in DIRECTIONS[cell[1] % 2]:
			var other = cell + direction
			if is_within_bounds(other):
				_astar.connect_points(cell_id, mti(other), false)

func is_within_bounds(cell: Vector2i) -> bool:
	return _tile_rect.has_point(cell)

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
		
		for next_id in _astar.get_point_connections(mti(current)):
			var next = itm(next_id)
			if is_occupied(next):
				continue
			if cells == 2 and is_occupied(next + Vector2i(1, 0)):
				continue
			if next in array:
				continue
	
			array.append(next)
			stack.append(next)

	return array


func _input(event: InputEvent):
	if event.is_action_pressed("move"):
		print(event)
		print(to_map(event.position))

"""
@export var count_tiles: int = 1

@onready var tile_map: TileMap = $"../../TileMap"
@onready var animation: AnimationPlayer = $"../AnimationPlayer"
@onready var root: Node2D = $".."

var astar_grid: AStarGrid2D
var curent_id_path: Array[Vector2i]

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2i(64,32)
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	astar_grid.update()


func _input(event):
	if event.is_action_pressed("move") == false:
		return
		
	var id_path = astar_grid.get_id_path(
		tile_map.local_to_map(root.global_position),
		tile_map.local_to_map(root.get_global_mouse_position())
	).slice(1)
	
	
	if id_path.is_empty() == false:
		curent_id_path = id_path
		
		
func _physics_process(_delta):
	if curent_id_path.is_empty():
		animation.play("idle")
		return
		
	var target_position = tile_map.map_to_local(curent_id_path.front())
	animation.play("run")
	root.global_position = root.global_position.move_toward(target_position, 3)
	
	if root.global_position == target_position:    
		curent_id_path.pop_front()
"""
