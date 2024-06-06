class_name SimplePOI extends ProcMapPOI

# position in chunks
@export var x_range: Vector2i = Vector2i(32, 32)
@export var y_range: Vector2i = Vector2i(32, 32)

# pressed circle radius
@export var radius: int = 5
# the thing to spawn 
@export var POIRes: Resource = null
	
var RNG = RandomNumberGenerator.new()
func place(pos: Vector2i):
	"""
	places POI and creates a hole for it
	DOES NOT create paths between POIs
	CHANGES tilemap.chunk_heightmaps[pos]
	
	 - pos - position of the chunk to which this POI belongs
	"""
	assert(POIRes != null, "You forgot to define POI for " + name)
	RNG.seed = tilemap.SEED
	chunk_pos = pos
	poi_pos = Vector2i(
			randi_range(x_range.x, x_range.y), 
			randi_range(y_range.x, y_range.y))
	tilemap.chunk_heightmaps[pos] = tilemap.press_circle(tilemap.chunk_heightmaps[pos], poi_pos, radius)
	var poi: TileEvent = POIRes.instantiate() 
	add_child(poi)
	poi.position = tilemap.local_to_map(poi_pos)
	global_position = tilemap.local_to_map(chunk_pos)
	
