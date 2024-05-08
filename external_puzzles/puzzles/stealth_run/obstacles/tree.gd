class_name StealthTree extends StealthObstacle


# pos is center
func place(pos: Vector2i):
	self.pos = pos
	for i in range(2):
		for j in range(2):
			set_unwalkable(pos - Vector2i(i, j))
	global_position = tilemap.map_to_local(pos)
