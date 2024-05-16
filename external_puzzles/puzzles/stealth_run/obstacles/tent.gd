class_name StealthTent extends StealthObstacle


enum Direction {
	North,
	East,
	South,
	West
}
var dir: Direction = Direction.North

func place(pos: Vector2i):
	self.pos = pos
	#if not 
		
	for i in range(-2, 3):
		if dir != Direction.North:
			set_unwalkable(pos + Vector2i(i, -2))
		if dir != Direction.South:
			set_unwalkable(pos + Vector2i(i, 2))
		if dir != Direction.East:
			set_unwalkable(pos + Vector2i(2, i))
		if dir != Direction.West:
			set_unwalkable(pos + Vector2i(-2, i))

	global_position = tilemap.map_to_local(pos) + Vector2(tilemap.tile_set.tile_size / 2)
	pass
