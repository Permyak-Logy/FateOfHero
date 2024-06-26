class_name WASDPlayer extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var puzzle = get_parent()
@onready var pos: Vector2i = Vector2i(5, 13)
@onready var moving: bool = false
#var speed = 20 * puzzle.tilemap.tile_set.tile_size
var speed = 1000
var next_move = null

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

func wasd_move(event):
	var delta = Vector2i(0, 0)
	if event.is_action_pressed("up"):
		delta[1] -= 1
	if event.is_action_pressed("down"):
		delta[1] += 1
	if event.is_action_pressed("left"):
		delta[0] -= 1
	if event.is_action_pressed("right"):
		delta[0] += 1
	if puzzle.tilemap.get_cell_tile_data(0, pos + delta).get_custom_data("walkable"):
		pos += delta
		sprite.frame = get_dir_from_vect(delta)

func _physics_process(delta):
	var target_position = puzzle.tilemap.map_to_local(pos)
	if global_position != target_position:
		moving = true
		var movement = global_position.move_toward(target_position, speed * delta) - global_position
		var collision = move_and_collide(movement)
		if collision:
			var collidor = collision.get_collider()
			if collidor.get_parent().has_method("activate"):
				collidor.get_parent().activate()
	else:
		if not puzzle.tilemap.get_cell_tile_data(0, pos).get_custom_data("safe"):
			puzzle.start_fight()
		if next_move:
			wasd_move(next_move)
			next_move = null
		moving = false


func _input(event):
	if event.is_action_pressed("up") \
	or event.is_action_pressed("down") \
	or event.is_action_pressed("left") \
	or event.is_action_pressed("right"):
		if not moving:
			wasd_move(event)
			moving = true
		else:
			next_move = event
	pass


func _ready():
	sprite.frame = Direction.South
	sprite.offset = Vector2i(0, -2)
	pass
