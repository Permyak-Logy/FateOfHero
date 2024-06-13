class_name SimplePOI extends ProcMapPOI

@export var POIRes: Resource

func place(pos: Vector2i):
	var c_hm = tilemap.chunk_heightmaps[pos]
	c_hm = tilemap.press_circle(c_hm, pos, radius)
	tilemap.chunk_heightmaps[pos] = c_hm
	chunk_pos = pos
	poi_pos = Vector2i(
		randi_range(poi_range_x.x, poi_range_x.y),
		randi_range(poi_range_y.x, poi_range_y.y))
	var poi: TileEvent = POIRes.instantiate()
	global_position = tilemap.local_to_map(chunk_pos * Chunk.SIZE)
	poi.position = poi_pos
	poi.removed.connect(queue_free)
	add_child(poi)
