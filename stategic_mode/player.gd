extends Node2D

@onready var tilemap =  $"../TileMap"

@export var inventory: Inventory

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var target_position: Vector2
var is_moving: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
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

func _input(event):
	if event.is_action_pressed("lmb") == false:
		return 
		
	var id_path
	print("global_position", global_position)
	print("mouse_position", get_global_mouse_position())
	print("clicked at: ",tilemap.local_to_map(get_global_mouse_position()))
	if is_moving:
		print(target_position)
		id_path = astar_grid.get_id_path(
			tilemap.local_to_map(target_position),
			tilemap.local_to_map(get_global_mouse_position())
		)
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
		print("abs tp: ", target_position)
		print("map tp: ", current_id_path.front())
		print("first_target: ", tilemap.local_to_map(target_position))
		is_moving = true
	
	global_position = global_position.move_toward(target_position, 8 * 16 * delta)
	
	if global_position == target_position:
		current_id_path.pop_front()
		if not current_id_path.is_empty():
			target_position = tilemap.map_to_local(current_id_path.front())
			target_position[0] -= 8
			target_position[1] -= 8
			print("next_target: ", tilemap.local_to_map(target_position))
		else:
			is_moving = false
			print("movement ended")
			
