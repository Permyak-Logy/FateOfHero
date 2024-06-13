class_name SimplePOI extends ProcMapPOI

# position in chunks
@export var x_range: Vector2i = Vector2i(32, 32)
@export var y_range: Vector2i = Vector2i(32, 32)

# pressed circle radius
@export var radius: int = 5
# the thing to spawn 
@export var POIRes: Resource = null

# because i need a set seed for debugging purposes
var possible_textures = [
	preload("res://strategic_mode/tile_events/sprites/house.png"),
	preload("res://strategic_mode/tile_events/sprites/tpr_safe_path.png")
]
var RNG = RandomNumberGenerator.new()
const VERBOSE = 0
	
	
func place(pos: Vector2i):
	"""
	places POI and creates a hole for it
	DOES NOT create paths between POIs
	CHANGES tilemap.chunk_heightmaps[pos]
	
	 - pos - position of the chunk to which this POI belongs
	"""
	assert(POIRes != null, "You forgot to define POI for " + name)
	assert(tilemap != null and strat_map != null)
	RNG.seed = tilemap.SEED * hash(pos)
	chunk_pos = pos
	poi_pos = Vector2i(
			randi_range(x_range.x, x_range.y), 
			randi_range(y_range.x, y_range.y))
	tilemap.chunk_heightmaps[pos] = tilemap.press_circle(tilemap.chunk_heightmaps[pos], poi_pos, radius)
	var poi: TileEvent = POIRes.instantiate() 
	poi.texture = possible_textures.pick_random()
	add_child(poi)
	poi.position = tilemap.map_to_local(poi_pos + chunk_pos * Chunk.SIZE)
	global_position = tilemap.map_to_local(chunk_pos)
	if VERBOSE: print(name, ": POI placed in chunk ", chunk_pos, " at ", poi_pos)
	
