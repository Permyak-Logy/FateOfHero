class_name StealthCampfire extends StealthObstacle


# pos is center
func place(pos: Vector2i):
	self.pos = pos
	for i in range(-2, 3):
		for j in range(-2, 3):
			set_unsafe(pos + Vector2i(i, j))
	for i in range(-1, 2):
		for j in range(-1, 2):
			set_unwalkable(pos + Vector2i(i, j))
	global_position = tilemap.map_to_local(pos) + Vector2(tilemap.tile_set.tile_size / 2)
	
