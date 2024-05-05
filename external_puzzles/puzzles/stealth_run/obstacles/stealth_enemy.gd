class_name StealthEnemy extends StaticBody2D

signal stealth_suicide(target: StealthEnemy)

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

enum State {
	sleep,
	awake,
	walking,
	panic
}
@onready var sprite: Sprite2D = $Sprite2D
@onready var puzzle: StealthRun = $".."
@onready var tilemap: TileMap =  $"../TileMap"

var original_pos: Vector2i
var pos: Vector2i
var view_direction: Direction
var original_view_direction: Direction
var player_close: bool = false

var state: State = State.awake
var next_state: State = State.awake
var clock: float = 0
var timer: float = 0

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var target_position: Vector2
var last_position: Vector2
var is_moving: bool = false

func place(pos: Vector2i, dir: Direction):
	self.pos = pos
	self.original_pos = pos
	view_direction = dir
	original_view_direction = dir
	global_position = puzzle.tilemap.map_to_local(pos)
	pass

func update():
	sprite.frame = view_direction

func move(delta):
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
		if is_instance_of(collidor.get_parent(), StealthPlayer):
			puzzle.start_combat()
	
	if global_position == target_position:
		pos = current_id_path.front()
		current_id_path.pop_front()
		if not current_id_path.is_empty():
			last_position = target_position
			target_position = tilemap.map_to_local(current_id_path.front())
			var dir = current_id_path.front() - pos
			if dir.y == -1:
				view_direction = Direction.North
			if dir.y == 1:
				view_direction = Direction.South
			if dir.x == 1:
				view_direction = Direction.East
			if dir.x == -1:
				view_direction = Direction.West
		else:
			is_moving = false
			


func see():
	pass

func _physics_process(delta):
	update()
	clock += delta
	timer = timer - delta if timer > delta else 0
	if state == State.sleep:
		if timer == 0:
			state = next_state
	see()
	if state == State.awake:
		if clock > 5:
			clock = 0
			if randi_range(0, 5) == 0:
				target_position = puzzle.get_random_tree().pos + Vector2i(0, 1)
				current_id_path = astar_grid.get_id_path(
					tilemap.local_to_map(global_position),
					target_position
				).slice(1)
				state = State.walking
	if state == State.walking:
		move(delta)
		if not current_id_path:
			if pos != original_pos:
				timer = 5
				next_state = State.walking
				state = State.sleep
				target_position = original_pos
				current_id_path = astar_grid.get_id_path(
						tilemap.local_to_map(global_position),
						target_position
					).slice(1)
				view_direction = Direction.North
			else:
				view_direction = original_view_direction
		

func _input(event):
	if event.is_action_pressed("spacebar"):
		if player_close:
			stealth_suicide.emit(self)


func _on_area_2d_body_exited(body):
	if is_instance_of(body, StealthPlayer):
		player_close = false


func _on_area_2d_body_entered(body):
	if is_instance_of(body, StealthPlayer):
		player_close = true


func _ready():
	pass 
	
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
			
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)
	
		
