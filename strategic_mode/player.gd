class_name Player extends CharacterBody2D

"""
Represents the character that moves on the strat map.
It moves itself and activates touch based tile events.
It finds path among the squares on the tilemap with walkable set to true.
"""

@onready var strat_map: StratMap = $".."
@onready var sprite: Sprite2D = $Sprite2D
@onready var tilemap: StratTileMap =  $"../StratTileMap"

@export var mc_name: String
@export var inventory: Inventory
@export var texture: Dictionary = {
	"default" : preload("res://strategic_mode/tile_events/sprites/gg_fidi_directional.png"),
	"Vamp" : preload("res://strategic_mode/tile_events/sprites/gg_vampire_directional.png"),
	"Berserk" : preload("res://strategic_mode/tile_events/sprites/gg_berserk_directional.png")
}

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

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var target_position: Vector2
var last_position: Vector2
var pos: Vector2i
var is_moving: bool = false
var direction: Direction = Direction.South


func _init():
	if not inventory:
		inventory = Inventory.new()

func update_nav_map(pos: Vector2i, state: bool):
	astar_grid.set_point_solid(pos, not state)

func gen_nav():
	pos = tilemap.local_to_map(global_position)
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
			astar_grid.set_point_solid(tile_position, not is_walkable(tile_position))
			

	tilemap.occupied_changed.connect(update_nav_map)

func _ready():
	if mc_name:
		sprite.texture = texture[mc_name]
	strat_map.strat_map_loaded.connect(gen_nav)

func is_walkable(pos: Vector2i) -> bool:
	var res = true
	var tile_data = tilemap.get_cell_tile_data(0, pos)
	if tile_data and tile_data.get_custom_data("walkable") == false:
		res = false
	# overwrite with terrain; so bridges and highlands are walkable
	for i in range(1, tilemap.get_layers_count()):
		tile_data = tilemap.get_cell_tile_data(i, pos)
		if tile_data:
			res = tile_data.get_custom_data("walkable")
	return res

func backtrack():
	global_position = last_position
	is_moving = false 
	current_id_path = []

func _input(event):
	if event.is_action_pressed("lmb"):
		print(event)
		var id_path
		if is_moving:
			print("stopping")
			target_position = last_position
			id_path = astar_grid.get_id_path(
				tilemap.local_to_map(global_position),
				tilemap.local_to_map(target_position)
			).slice(1)
			is_moving = false
		else:
			id_path = astar_grid.get_id_path(
				tilemap.local_to_map(global_position),
				tilemap.local_to_map(get_global_mouse_position())
			).slice(1)
		print(id_path)
		current_id_path = id_path
		return

	var delta = Vector2i(0, 0)
	if event.is_action_pressed("up"):
		delta[1] -= 1
	if event.is_action_pressed("down"):
		delta[1] += 1
	if event.is_action_pressed("left"):
		delta[0] -= 1
	if event.is_action_pressed("right"):
		delta[0] += 1
	if current_id_path.size() > 2 and (delta.x != 0 or delta.y != 0):
		current_id_path = [current_id_path.front()]
	if current_id_path.is_empty():
		if astar_grid.is_point_solid(pos + delta) == false and (delta.x != 0 or delta.y != 0):
			current_id_path.append(pos + delta)
	else:
		if astar_grid.is_point_solid(current_id_path.back() + delta) == false and (delta.x != 0 or delta.y != 0):
			current_id_path.append(current_id_path.back() + delta)

func get_dir_from_vect(vect: Vector2i) -> Direction:
	if vect == Vector2i(0, -1):
		return Direction.North
	elif vect == Vector2i(1, -1):
		return Direction.East
	elif vect == Vector2i(1, 0):
		return Direction.East
	elif vect == Vector2i(1, 1):
		return Direction.East
	elif vect == Vector2i(0, 1):
		return Direction.South
	elif vect == Vector2i(-1, 1):
		return Direction.West
	elif vect == Vector2i(-1, 0):
		return Direction.West
	else:
		return Direction.West


func _physics_process(delta):
	sprite.frame = direction
	if current_id_path.is_empty():
		return
	
	if is_moving == false:
		target_position = tilemap.map_to_local(current_id_path.front())
		target_position[0] -= 8
		target_position[1] -= 8
		is_moving = true
		direction = get_dir_from_vect(current_id_path.front() - pos)

	
	var movement = global_position.move_toward(target_position, 8 * 16 * delta) - global_position
	var collision = move_and_collide(movement)
	
	if collision:
		var collidor = collision.get_collider()
		if not is_instance_of(collidor, Unit):
			collidor.activate()
	
	if global_position == target_position:
		current_id_path.pop_front()
		last_position = target_position
		pos = tilemap.local_to_map(last_position)
		if not current_id_path.is_empty():
			target_position = tilemap.map_to_local(current_id_path.front())
			direction = get_dir_from_vect(current_id_path.front() - pos)
			target_position[0] -= 8
			target_position[1] -= 8
			strat_map.move_time(30)
		else:
			is_moving = false

func move_to(new_pos: Vector2i):
	var new_local_pos = tilemap.map_to_local(new_pos) + Vector2(8, 8)
	last_position = global_position
	pos = tilemap.local_to_map(last_position)
	global_position = new_local_pos
	current_id_path = []
	target_position = new_pos
	is_moving = false
