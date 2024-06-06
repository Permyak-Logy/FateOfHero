class_name SpawnPOI extends SimplePOI

func place(pos: Vector2i):
	assert(POIRes == null, "do not mess with this setting")
	RNG.seed = tilemap.SEED
	chunk_pos = pos
	poi_pos = Vector2i(
			randi_range(x_range.x, x_range.y), 
			randi_range(y_range.x, y_range.y))
	tilemap.chunk_heightmaps[pos] = tilemap.press_circle(tilemap.chunk_heightmaps[pos], poi_pos, radius)
	global_position = tilemap.local_to_map(chunk_pos)
	strat_map.player.move_to(chunk_pos * Chunk.SIZE + poi_pos)
	
