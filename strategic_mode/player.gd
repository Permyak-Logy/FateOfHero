class_name Player extends CharacterBody2D

"""
Represents the character that moves on the strat map.
It moves itself and activates touch based tile events.
It finds path among the squares on the tilemap with walkable set to true.
"""

@onready var strat_map: StratMap = $".."
@onready var tilemap: StratTileMap =  $"../StratTileMap"
@onready var TileEvent = preload("res://strategic_mode/tile_events/TileEvent.tscn")
@export var inventory: Inventory

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var target_position: Vector2
var last_position: Vector2
var is_moving: bool = false

func update_nav_map():
	
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
			
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)


func _ready():
	update_nav_map()
	tilemap.strat_map_walkability_changed.connect(update_nav_map)
		
func _input(event):
	if event.is_action_pressed("lmb") == false:
		return 
		
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


func _physics_process(delta):
	if current_id_path.is_empty():
		return
	
	if is_moving == false:
		target_position = tilemap.map_to_local(current_id_path.front())
		target_position[0] -= 8
		target_position[1] -= 8
		is_moving = true
	
	var movement = global_position.move_toward(target_position, 8 * 16 * delta) - global_position
	var collision = move_and_collide(movement)
	
	if collision:
		var collidor = collision.get_collider()
		collidor.activate()
	
	if global_position == target_position:
		current_id_path.pop_front()
		if not current_id_path.is_empty():
			last_position = target_position
			target_position = tilemap.map_to_local(current_id_path.front())
			target_position[0] -= 8
			target_position[1] -= 8
			strat_map.move_time(30)
		else:
			is_moving = false
			

func move_to(new_pos: Vector2i):
	var new_local_pos = tilemap.map_to_local(new_pos) + Vector2(8, 8)
	last_position = global_position
	global_position = new_local_pos
	current_id_path = []
	target_position = new_pos
	is_moving = false
