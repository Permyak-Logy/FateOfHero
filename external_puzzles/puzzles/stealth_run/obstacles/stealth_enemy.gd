class_name StealthEnemy extends StaticBody2D

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
	pee,
	panic
}
@onready var sprite: Sprite2D = $Sprite2D
@onready var puzzle: StealthRun = get_parent()

var pos: Vector2i
var view_direction: Direction = Direction.North

func place(pos: Vector2i, dir: Direction):
	self.pos = pos
	view_direction = dir
	global_position = puzzle.tilemap.map_to_local(pos)
	pass

func update():
	pass

func move():
	pass

func _physics_process(delta):
	sprite.frame = view_direction
	pass
