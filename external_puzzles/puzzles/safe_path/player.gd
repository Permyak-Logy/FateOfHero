extends CharacterBody2D

class_name wasd_player


@onready var puzzle: SafePath = get_parent()

@onready var pos: Vector2i = Vector2i(5, 13)
@onready var moving: bool = false
#var speed = 20 * puzzle.tilemap.tile_set.tile_size
var speed = 1000
var next_move = null

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

func _physics_process(delta):
	var target_position = puzzle.tilemap.map_to_local(pos)
	if global_position != target_position:
		moving = true
		var movement = global_position.move_toward(target_position, speed * delta) - global_position
		move_and_collide(movement)
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


func _ready():
	pass
