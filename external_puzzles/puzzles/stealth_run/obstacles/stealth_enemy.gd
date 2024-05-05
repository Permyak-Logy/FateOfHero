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

enum State{
	sleep,
	awake,
	pee,
	panic
	
}

@onready var puzzle: StealthRun = get_parent()

var view_direction: Direction = Direction.North

func update():
	pass

func move():
	pass

func _physics_process(delta):
	pass
