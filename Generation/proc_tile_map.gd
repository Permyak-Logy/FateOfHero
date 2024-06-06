class_name ProcTileMap extends StratTileMap

@onready var sm: ProceduralStratMap = get_parent()
# Distrance in chunks at which chunks start generating
const GENERATION_DISTANCE = 1
#@export var SEED = randi()
@export var SEED = 3453287850

# you can't access the same layer from several threads
var tilemap_mutex: Mutex = Mutex.new()
var terrains: Array[Array]
var current_terrain_slot: int = 0

var hightmap_mutex: Mutex = Mutex.new()
@export var chunk_heightmaps: Dictionary = {}
@export var major_POIs: Dictionary = {}
@export var drawn_chunks: Array[Vector2i] = []

var drawer_semafore: Semaphore = Semaphore.new()
var gen_thread: Thread
var gen_queue_mutex: Mutex = Mutex.new()
var gen_queue: Array[Vector2i]

var major_POI_Reses: Dictionary = {
	0 : preload("res://Generation/POIs/spawn_poi.tscn"),
	1 : preload("res://Generation/POIs/simple_poi.tscn"),
}

signal gen_queue_empty()


func gen_world():
	print(SEED)
	gen_heightmap(Vector2i(0, 0))
	var spawn_chunk_hm = chunk_heightmaps[Vector2i(0, 0)]
	chunk_heightmaps[Vector2i(0, 0)] = spawn_chunk_hm
	var spawn_poi: SpawnPOI = major_POI_Reses[0].instantiate()
	add_child(spawn_poi)
	spawn_poi.place(Vector2i(0, 0))
	var spawn_chunk: Chunk = gen_chunk(Vector2i(0, 0))
	major_POIs[Vector2i(0, 0)] = spawn_poi
	draw_chunk(spawn_chunk)
	drawn_chunks.append(Vector2i(0, 0))
	
	gen_thread = Thread.new()
	gen_thread.start(gen_job, Thread.PRIORITY_NORMAL)
	# generate initial chunks
	on_player_moved(Vector2i(0,  0))
	sm.player.moved.connect(on_player_moved)
	

func gen_heightmap(cpos: Vector2i):
	"""
	generates terrain heightmap of the chunk
	it will be modified later be gen_poi, gen_path, etc.
	"""
	var height_map:Array[Array] = []
	var noise_gen = FastNoiseLite.new()
	noise_gen.noise_type = FastNoiseLite.TYPE_PERLIN
	noise_gen.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise_gen.frequency = 0.03
	noise_gen.seed = SEED
	
	var noise_gen_2 = FastNoiseLite.new()
	noise_gen_2.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise_gen_2.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise_gen_2.frequency = 0.015
	noise_gen_2.seed = SEED
	
	for i in range(Chunk.SIZE):
		height_map.append([])
		for j in range(Chunk.SIZE):
			var x = cpos.x * Chunk.SIZE + i
			var y = cpos.y * Chunk.SIZE + j
			var v1 = noise_gen.get_noise_2d(x, y)
			var v2 = noise_gen_2.get_noise_2d(x, y)
			
			var val = v1 * 10 + v2 * 10
			#val = abs(val)
			val = val + 1
			height_map[i].append(val)
	hightmap_mutex.lock()
	chunk_heightmaps[cpos] = height_map
	hightmap_mutex.unlock()

func gen_poi(cpos: Vector2i):
	"""
	generates major POI and adds it to major_POIs[cpos]
	modifies chunk_heightmaps[cpos]
	"""
	hightmap_mutex.lock()
	
	hightmap_mutex.unlock()

func gen_chunk(cpos: Vector2i) -> Chunk:
	var chunk: Chunk = Chunk.create(cpos, chunk_heightmaps[cpos][cpos.x][cpos.y])
	var heightmap: Array[Array] = chunk_heightmaps[cpos]
	for x in range(Chunk.SIZE):
		for y in range(Chunk.SIZE):
			var layer = int(heightmap[x][y])
			layer = int(layer)
			for lid in range(1, min(layer, 5)):
				chunk.blocks[lid][x][y] = 8
	return chunk

func get_group(pos: Vector2i):
	var p = pos.x * 2 + int(pos.x > 0) + pos.y * 2 + int(pos.y > 0)
	return p % len(terrains)

func gen_job():
	while (true):
		gen_queue_mutex.lock()
		if gen_queue.is_empty():
			print("gen_job: waiting at semafore")
			gen_queue_mutex.unlock()
			drawer_semafore.wait()
		else:
			gen_queue_mutex.unlock()
			
		print("gen_job: staring to work")
		
		while (gen_queue.is_empty() == false):
			gen_queue_mutex.lock()
			var target = gen_queue.pop_front()
			gen_queue_mutex.unlock()
			print("gen_job: genning chunk ", target)
			gen_and_draw_chunk(target)
		call_deferred("finalize_gen")

func signal_queue_empty():
	gen_queue_empty.emit()


func gen_and_draw_chunk(cpos: Vector2i):
	call_deferred("mark_as_genned", cpos)
	for i in range(-1, 2):
		for j in range(-1, 2):
			if not (cpos + Vector2i(i, j)) in chunk_heightmaps.keys():
				gen_heightmap(cpos + Vector2i(i, j))
			if not (cpos + Vector2i(i, j)) in major_POIs.keys():
				major_POIs[cpos] = null
	
	var poi_count = randi_range(1, 4)
	for i in range(poi_count):
		var poi_ripos = randi_range(0, 8) # relative int pos
		if not major_POIs.get(cpos + Vector2i(poi_ripos / 3 - 1, poi_ripos % 3 - 1), null):
			gen_poi(cpos + Vector2i(poi_ripos / 3, poi_ripos % 3))
	var chunk: Chunk = gen_chunk(cpos)
	draw_chunk(chunk)
	

func draw_chunk(chunk: Chunk):
	"""
	can be called assinchronously 
	sets terrains in tilemap for given chunk
	the slow part is set_cells_terrain_connect
	only one thread can modify one layer at a time
	"""
	print("draw_chunk ", chunk.pos, ": ", "starting drawing chunk ", chunk.pos)
	tilemap_mutex.lock()
	print("draw_chunk ", chunk.pos, ": ", "captured terrain")
	terrains.clear()
	terrains = [
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []]
	]
	print("draw_chunk ", chunk.pos, ": ", "initialized terrain")
	
	for layer in range(Chunk.LAYER_COUNT):
		#print("loaded layer: ", layer)
		for x in range(Chunk.SIZE):
			for y in range(Chunk.SIZE):
				if chunk.blocks[layer][x][y] == -1:
					continue
				var rpos = Vector2i(x + Chunk.SIZE * chunk.pos.x, y + Chunk.SIZE * chunk.pos.y) 
				terrains[layer][chunk.blocks[layer][x][y]].append(rpos)
				
	print("draw_chunk ", chunk.pos, ": ", "loaded chunk")
	
	
	var threads: Array[Thread] = []
	for layer in range(Chunk.LAYER_COUNT):
		var c = draw_layer
		c = c.bind(layer)
		var t: Thread = Thread.new()
		t.start(c, Thread.PRIORITY_NORMAL)
		threads.append(t)
	print("draw_chunk ", chunk.pos, ": ", "dispatched threads")
	
	var cp = chunk.pos * Chunk.SIZE 
	var border: Array[Array] = [[],[],[],[]]
	for i in range(Chunk.SIZE):
		sm.tilemap.set_cell(0, cp + Vector2i(i, 0), 0, Vector2i(randi_range(0, 2), randi_range(0, 1)))
		sm.tilemap.set_cell(0, cp + Vector2i(0, i), 0, Vector2i(randi_range(0, 2), randi_range(0, 1)))
		sm.tilemap.set_cell(0, cp + Vector2i(Chunk.SIZE, i), 0, Vector2i(randi_range(0, 2), randi_range(0, 1)))
		sm.tilemap.set_cell(0, cp + Vector2i(i, Chunk.SIZE), 0, Vector2i(randi_range(0, 2), randi_range(0, 1)))
	for t in threads:
		t.wait_to_finish()
	print("draw_chunk ", chunk.pos, ": ", "done drawing")
	tilemap_mutex.unlock()
	print("---------------------------------")

func draw_layer(layer: int):
	for terrain_id in range(14):
		set_cells_terrain_connect(layer, terrains[layer][terrain_id], terrain_id / 8, terrain_id % 8, true)


func press_circle(height_map: Array[Array], pos: Vector2i, radius: float) -> Array[Array]:
	"""
	makes a cirle of flat terrain at height 0 that gradually transitions to normal terrain
	works within a chunk
	DOES NOT change `chunk_heightmaps`
	
	 - height_map - height map of a chunk
	 - pos - local position
	 - radius
	"""
	for x in range(min(0,(pos.x - int(radius) * 2)), min(16 * Chunk.SIZE, pos.x + int(radius) * 2)):
		for y in range(pos.y - int(radius) - 5, pos.y + int(radius) + 5):
			if (pos - Vector2i(x, y)).length() < radius:
				height_map[x][y] *= 0
			elif (pos - Vector2i(x, y)).length() < radius * 2:
				height_map[x][y] *= ((pos - Vector2i(x, y)).length() - radius) ** 2
				
	return height_map

func mark_as_genned(cpos: Vector2i):
	drawn_chunks.append(cpos)

func regen_navmap():
	sm.player.regen_nav()


func on_player_moved(pos: Vector2i):
	for i in range(-GENERATION_DISTANCE, GENERATION_DISTANCE + 1):
		for j in range(-GENERATION_DISTANCE, GENERATION_DISTANCE + 1):
			var chunk_pos = ((pos - Vector2i(32, 32)) / Chunk.SIZE) + Vector2i(i, j)
			gen_queue_mutex.lock()
			if not (chunk_pos in drawn_chunks or chunk_pos in gen_queue):
				print("on_player_moved: queued to draw: ", chunk_pos)
				gen_queue.append(chunk_pos)
				if gen_queue.size() == 1:
					print("on_player_moved: posting to gen semafore")
					drawer_semafore.post()
			gen_queue_mutex.unlock()
				
func finalize_gen():
	tilemap_mutex.lock()
	regen_navmap()
	for layer in range(Chunk.LAYER_COUNT):
		set_layer_enabled(layer, false)
		notify_runtime_tile_data_update(layer)
		update_internals()
		set_layer_enabled(layer, true)
	print("reloaded layers")
	tilemap_mutex.unlock()
