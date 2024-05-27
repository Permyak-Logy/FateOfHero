class_name SpawnBlackHole extends AoEAbility

@export var black_hole = preload("res://tactical_mode/unit/units/BlackHole/BlackHole.tscn")

func apply():
	var actor = get_map().spawn(black_hole, cell)

func can_select(_cell: Vector2i):
	if not super(_cell):
		return false
	return not get_map().is_occupied(_cell)
