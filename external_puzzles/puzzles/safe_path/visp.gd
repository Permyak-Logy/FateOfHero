class_name SafePathVisp extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var puzzle: SafePath = $".."
@onready var tilemap: TileMap =  $"../TileMap"

signal target_reaced(visp: SafePathVisp)

enum Direction {
	North,
	NorthEast,
	East,
	SouthEast,
	South,
	SouthWest,
	West,
	NorthWest
}

var original_pos: Vector2i
var pos: Vector2i
var view_direction: Direction
var original_view_direction: Direction
var player_close: bool = false

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var target_position: Vector2
var last_position: Vector2
var is_moving: bool = false

const speed = 16 * 8

var start: Vector2i
var end: Vector2i


func get_vect_from_dir(dir: Direction) -> Vector2i:
	var vec: Vector2i = Vector2i(0, 0)
	if dir <= 1 or dir == 7:
		vec += Vector2i(0, -1) 
	if 1 <= dir and dir <= 3:
		vec += Vector2i(1, 0)
	if 3 <= dir and dir <= 5:
		vec += Vector2i(0, 1)
	if 5 <= dir and dir <= 7:
		vec += Vector2i(-1, 0)
	return vec

func get_dir_from_vect(vect: Vector2i) -> Direction:
	if vect == Vector2i(0, -1):
		return Direction.North
	elif vect == Vector2i(1, -1):
		return Direction.NorthEast
	elif vect == Vector2i(1, 0):
		return Direction.East
	elif vect == Vector2i(1, 1):
		return Direction.SouthEast
	elif vect == Vector2i(0, 1):
		return Direction.South
	elif vect == Vector2i(-1, 1):
		return Direction.SouthWest
	elif vect == Vector2i(-1, 0):
		return Direction.West
	else:
		return Direction.NorthWest
	

func update():
	sprite.frame = view_direction

func move(delta):
	if current_id_path.is_empty():
		target_reaced.emit(self)
		return
	
	if is_moving == false:
		target_position = tilemap.map_to_local(current_id_path.front())
		view_direction = get_dir_from_vect(current_id_path.front() - pos)
		update() 
		is_moving = true
	
	global_position = global_position.move_toward(target_position, speed * delta)
	
	
	if global_position == target_position:
		pos = current_id_path.front()
		current_id_path.pop_front()
		if not current_id_path.is_empty():
			last_position = target_position
			target_position = tilemap.map_to_local(current_id_path.front())
			view_direction = get_dir_from_vect(current_id_path.front() - pos)
			update()
		else:
			is_moving = false

func _physics_process(delta):
	update()
	move(delta)

func _ready():
	setup_nav()
	pos = start
	global_position = puzzle.tilemap.map_to_local(pos)
	current_id_path = astar_grid.get_id_path(
						start,
						end
					).slice(1)

func setup_nav():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tilemap.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16) 
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	for x in tilemap.get_used_rect().size.x:
		for y in tilemap.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tilemap.get_used_rect().position.x,
				y + tilemap.get_used_rect().position.y
				)
			var tile_data = tilemap.get_cell_tile_data(0, tile_position)
			
			if tile_data == null or tile_data.get_custom_data("safe") == false:
				astar_grid.set_point_solid(tile_position)
	
		


