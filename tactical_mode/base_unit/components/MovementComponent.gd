extends Node
class_name MovementComponent

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
