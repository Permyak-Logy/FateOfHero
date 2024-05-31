class_name ProcTileMap extends StratTileMap

@onready var sm: ProceduralStratMap = get_parent()
# size of the world in chunks
const GENERATION_DISTANCE = 3
#@export var SEED = randi()
@export var SEED = 3453287850

# you can't access the same layer from several threads
var tilemap_mutex: Mutex = Mutex.new()
var terrains: Array[Array]
var current_terrain_slot: int = 0

var hightmap_mutex: Mutex = Mutex.new()
var chunk_heightmaps: Dictionary = {}
@export var drawn_chunks: Array[Vector2i] = []



signal superchunk_generated(cpos: Vector2i)

var gen_thread: Thread
var drawer_threads: Array[Thread] = []

func gen_world():
	print(SEED)
	gen_heightmap(Vector2i(0, 0))
	var spawn_chunk_hm = chunk_heightmaps[Vector2i(0, 0)]
	spawn_chunk_hm = press_circle(
		spawn_chunk_hm, Vector2i(Chunk.SIZE  / 2, Chunk.SIZE / 2), 5)
	chunk_heightmaps[Vector2i(0, 0)] = spawn_chunk_hm
	var spawn_chunk: Chunk = gen_chunk(Vector2i(0, 0))
	draw_chunk(spawn_chunk)
	drawn_chunks.append(Vector2i(0, 0))
	
	for i in range(-GENERATION_DISTANCE, GENERATION_DISTANCE + 1):
		for j in range(-GENERATION_DISTANCE, GENERATION_DISTANCE + 1):
			var chunk_pos = Vector2i(i, j)
			if not (chunk_pos in drawn_chunks):
				print("attemptint to draw chunk: ", chunk_pos)
				var dt = Thread.new()
				var c = Callable(gen_and_draw_chunk)
				dt.start(c.bind(chunk_pos), Thread.PRIORITY_LOW)
				drawer_threads.append(dt)
	for t in drawer_threads:
		t.wait_to_finish()
	drawer_threads.clear()
	regen_navmap()
	notify_runtime_tile_data_update()

func gen_heightmap(cpos: Vector2i):
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
	
	

func gen_chunk(cpos: Vector2i) -> Chunk:
	var chunk: Chunk = Chunk.create(cpos, chunk_heightmaps[cpos][cpos.x][cpos.y])
	for x in range(Chunk.SIZE):
		for y in range(Chunk.SIZE):
			var layer = int(chunk_heightmaps[cpos][x][y])
			layer = int(layer)
			for lid in range(1, min(layer, 5)):
				chunk.blocks[lid][x][y] = 8
	return chunk

func get_group(pos: Vector2i):
	var p = pos.x * 2 + int(pos.x > 0) + pos.y * 2 + int(pos.y > 0)
	return p % len(terrains)

func draw_chunk(chunk: Chunk):
	
	print("draw_chunk ", chunk.pos, ": ", "starting drawing chunk ", chunk.pos)
	tilemap_mutex.lock()
	print("draw_chunk ", chunk.pos, ": ", "captured terrain")
	terrains = [
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []]
	]
	print("draw_chunk ", chunk.pos, ": ", "initialized terrain")
	
	for layer in range(Chunk.LAYER_COUNT):
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
	for x in range(min(0,(pos.x - int(radius) * 2)), min(16 * Chunk.SIZE, pos.x + int(radius) * 2)):
		for y in range(pos.y - int(radius) - 5, pos.y + int(radius) + 5):
			#var delta = 
			if (pos - Vector2i(x, y)).length() < radius:
				height_map[x][y] *= 0.01
			elif (pos - Vector2i(x, y)).length() < radius * 2:
				height_map[x][y] *= ((pos - Vector2i(x, y)).length() - radius) ** 2
				
	return height_map

func mark_as_genned(cpos: Vector2i):
	drawn_chunks.append(cpos)

func regen_navmap():
	sm.player.regen_nav()

func gen_and_draw_chunk(cpos: Vector2i):
	# superchunk generator job is hella fast
	call_deferred("mark_as_genned", cpos)
	gen_heightmap(cpos)
	# we spin for 1 frame
	while not chunk_heightmaps.has(cpos): continue
	var chunk: Chunk = gen_chunk(cpos)
	draw_chunk(chunk)
	call_deferred("prune_drawers")

func on_player_moved(pos: Vector2i):
	for i in range(-GENERATION_DISTANCE, GENERATION_DISTANCE + 1):
		for j in range(-GENERATION_DISTANCE, GENERATION_DISTANCE + 1):
			var chunk_pos = ((pos - Vector2i(32, 32)) / Chunk.SIZE) + Vector2i(i, j)
			if not (chunk_pos in drawn_chunks):
				print("attemptint to draw chunk: ", chunk_pos)
				var dt = Thread.new()
				var c = Callable(gen_and_draw_chunk)
				dt.start(c.bind(chunk_pos), Thread.PRIORITY_LOW)
				drawer_threads.append(dt)

func prune_drawers():
	var removed_thread = false
	for t in drawer_threads:
		if not t.is_alive():
			t.wait_to_finish()
			drawer_threads.remove_at(drawer_threads.find(t))
			removed_thread = true
	if drawer_threads.is_empty() and removed_thread:
		regen_navmap()
		for layer in range(Chunk.LAYER_COUNT):
			set_layer_enabled(layer, false)
			notify_runtime_tile_data_update(layer)
			update_internals()
			set_layer_enabled(layer, true)
		print("reloaded layers")
