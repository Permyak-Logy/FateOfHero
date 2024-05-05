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

var speed = 16 * 1

func place(pos: Vector2i, dir: Direction):
	self.pos = pos
	self.original_pos = pos
	view_direction = dir
	original_view_direction = dir
	global_position = puzzle.tilemap.map_to_local(pos)
	see()
	pass


func set_unsafe(target_pos: Vector2i):
	tilemap.set_cell(0, target_pos, 0, Vector2i(0, 0)) 

func set_safe(target_pos: Vector2i):
	tilemap.set_cell(0, target_pos, 0, Vector2i(1, 0)) 

func set_unwalkable(target_pos: Vector2i):
	tilemap.set_cell(0, target_pos, 0, Vector2i(2, 0)) 

func is_walkable(target_pos: Vector2i):
	if not tilemap.get_cell_tile_data(0, target_pos):
		return false
	return tilemap.get_cell_tile_data(0, target_pos).get_custom_data("walkable")

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
	look(view_direction)

func move(delta):
	if current_id_path.is_empty():
		return
	
	if is_moving == false:
		view_direction = get_dir_from_vect(current_id_path.front() - pos)
		update() 
		target_position = tilemap.map_to_local(current_id_path.front())
		is_moving = true
	
	var movement = global_position.move_toward(target_position, speed * delta) - global_position
	var collision = move_and_collide(movement)
	
	if collision:
		var collidor = collision.get_collider()
		if is_instance_of(collidor.get_parent(), StealthPlayer):
			puzzle.start_combat()
	
	if global_position == target_position:
		unsee()
		pos = current_id_path.front()
		current_id_path.pop_front()
		if not current_id_path.is_empty():
			last_position = target_position
			target_position = tilemap.map_to_local(current_id_path.front())
			view_direction = get_dir_from_vect(current_id_path.front() - pos)
			update()
			see()
		else:
			is_moving = false
			
func unsee():
	set_safe(pos)
	for i in range(-1, 2):
		if is_walkable(pos + get_vect_from_dir((view_direction + 8 + i) % 8)):
			set_safe(pos + get_vect_from_dir((view_direction + 8 + i) % 8))
		if is_walkable(pos +  2 * get_vect_from_dir((view_direction + 8 + i) % 8)):
			set_safe(pos +  2 * get_vect_from_dir((view_direction + 8 + i) % 8))
		if is_walkable(pos + get_vect_from_dir((view_direction + 8 + i) % 8) + get_vect_from_dir(view_direction)):
			set_safe((pos + get_vect_from_dir((view_direction + 8 + i) % 8) + get_vect_from_dir(view_direction)))

func see():
	"""
	i will be dumb and just set the walkable tilesin front of it unsafe
	and then set in back safe
	"""
	set_unsafe(pos)
	for i in range(-1, 2):
		if is_walkable(pos + get_vect_from_dir((view_direction + 8 + i) % 8)):
			set_unsafe(pos + get_vect_from_dir((view_direction + 8 + i) % 8))
		if is_walkable(pos +  2 * get_vect_from_dir((view_direction + 8 + i) % 8)):
			set_unsafe(pos +  2 * get_vect_from_dir((view_direction + 8 + i) % 8))
		if is_walkable(pos + get_vect_from_dir((view_direction + 8 + i) % 8) + get_vect_from_dir(view_direction)):
			set_unsafe((pos + get_vect_from_dir((view_direction + 8 + i) % 8) + get_vect_from_dir(view_direction)))
		

func look(dir: Direction):
	unsee()
	view_direction = dir 
	see()

func _physics_process(delta):
	update()
	clock += delta
	timer = timer - delta if timer > delta else 0
	if state == State.sleep:
		if timer == 0:
			state = next_state
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
				look(Direction.North)
			else:
				view_direction = original_view_direction
		

func _input(event):
	if event.is_action_pressed("spacebar"):
		if player_close:
			unsee()
			stealth_suicide.emit(self)


func _on_area_2d_body_exited(body):
	if is_instance_of(body, StealthPlayer):
		player_close = false


func _on_area_2d_body_entered(body):
	if is_instance_of(body, StealthPlayer):
		player_close = true


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
	
		
