class_name ProcTileMap extends StratTileMap

@onready var sm: ProceduralStratMap = get_parent()
# size of the world in chunks
const SUPERCHUNK_SIZE = 4
const GENERATION_DISTANCE = 2
#@export var SEED = randi()
@export var SEED = 3453287850
# array[array[array[Vector2i]]] indexed as layer_id, terrain_id, tile_id
var terraints_mutex: Mutex = Mutex.new()
var player_nav_map_mutex: Mutex = Mutex.new()
var terrains: Array[Array]
#array[array[chunk]]
# superchunk pos -> superchunk height map
# i have no idea how to deal with the negatives othervise
var superchunks_heightmaps: Dictionary = {}
@export var drawn_scs: Array[Vector2i] = []

signal superchunk_generated(cpos: Vector2i)

var gen_thread: Thread
var drawer_threads: Array[Thread] = []

func gen_world():
	print(SEED)
	var spawn_chunks_hm = gen_height_map(0, 0)
	spawn_chunks_hm = press_circle(spawn_chunks_hm, Vector2i(
		SUPERCHUNK_SIZE  * 16 / 2, SUPERCHUNK_SIZE  * 16 / 2), 5)
	print(spawn_chunks_hm[32][32])
	var spawn_chunks = gen_chunks(spawn_chunks_hm, 0, 0)
	superchunks_heightmaps[Vector2i(0, 0)] = spawn_chunks_hm
	draw_world(spawn_chunks)
	drawn_scs.append(Vector2i(0, 0))
	start_generation_job()

func start_generation_job():
	gen_thread = Thread.new()
	gen_thread.start(generation_job, Thread.PRIORITY_LOW)
	

func init_chunks(cx, cy) -> Array[Array]:
	var chunks: Array[Array] = []
	for x in range(SUPERCHUNK_SIZE):
		chunks.append([])
		for y in range(SUPERCHUNK_SIZE):
			var chunk = Chunk.new()
			var rx = x + cx * SUPERCHUNK_SIZE
			var ry = y + cy * SUPERCHUNK_SIZE
			chunk.pos = Vector2i(rx, ry)
			chunks[x].append(chunk)
	return chunks

func gen_height_map(cx, cy) -> Array[Array]:
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
	
	#sm.noise_img.texture = ImageTexture.create_from_image(
		#noise_gen.get_image(SUPERCHUNK_SIZE * 16, SUPERCHUNK_SIZE * 16))
	for i in range(SUPERCHUNK_SIZE * 16):
		height_map.append([])
		for j in range(SUPERCHUNK_SIZE * 16):
			var rx = i +  cx * SUPERCHUNK_SIZE * 16
			var ry = j +  cy * SUPERCHUNK_SIZE * 16
			var v1 = noise_gen.get_noise_2d(rx, ry)
			var v2 = noise_gen_2.get_noise_2d(rx, ry)
			var val = v1 * 10 + v2 * 10
			#val = abs(val)
			val = val + 1
			height_map[i].append(val)
	#print(height_map)
	return height_map

func gen_chunks(height_map: Array[Array], cx, cy) -> Array[Array]:
	var chunks: Array[Array] = init_chunks(cx, cy)
	var mrx = 0
	var mry = 0
	for i in range(SUPERCHUNK_SIZE):
		for j in range(SUPERCHUNK_SIZE):
			var chunk: Chunk = chunks[i][j]
			for x in range(16):
				for y in range(16):
					var rx = 16 * i + x
					var ry = 16 * j + y
					#var layer = abs(noise_gen.get_noise_2d(rx, ry) * 10) 
					var layer = int(height_map[rx][ry])
					layer = int(layer)
					for lid in range(1, min(layer, 5)):
						chunk.blocks[lid][x][y] = 8
	return chunks

func draw_world(chunks: Array[Array]):
	print("starting drawing world")
	terraints_mutex.lock()
	print("captured terrain")
	terrains = [
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []]
	]
	print("initialized terrain")
	for x in range(SUPERCHUNK_SIZE):
		for y in range(SUPERCHUNK_SIZE):
			load_chunk(chunks[x][y])
	var threads: Array[Thread] = []
	print("loaded chunks")
	for layer in range(5):
		var c = draw_layer
		c = c.bind(layer)
		var t: Thread = Thread.new()
		t.start(c, Thread.PRIORITY_NORMAL)
		threads.append(t)
	print("dispatched threads")
	var cp = chunks[0][0].pos * 16
	var border: Array[Array] = [[],[],[],[]]
	for i in range(64):
		sm.tilemap.set_cell(0, cp + Vector2i(i, 0), 0, Vector2i(1, 1))
		sm.tilemap.set_cell(0, cp + Vector2i(0, i), 0, Vector2i(1, 1))
		sm.tilemap.set_cell(0, cp + Vector2i(63, i), 0, Vector2i(1, 1))
		sm.tilemap.set_cell(0, cp + Vector2i(i, 63), 0, Vector2i(1, 1))
	for t in threads:
		t.wait_to_finish()
	print("done drawing")
	terraints_mutex.unlock()

func rpnm():
	sm.player.regen_nav()
	#if player_nav_map_mutex.try_lock():
		#player_nav_map_mutex.unlock()

func draw_layer(layer: int):
	for terrain_id in range(14):
		#if layer == 0:
			#print(Vector2i(0, 0) in terrains[0][0])
		set_cells_terrain_connect(
			layer, terrains[layer][terrain_id], terrain_id / 8, terrain_id % 8)

func load_chunk(chunk: Chunk):
	for layer in range(min(5, chunk.blocks.size())):
		for x in range(16):
			for y in range(16):
				var real_pos = 16 * chunk.pos + Vector2i(x, y)
				if chunk.blocks[layer][x][y] == -1:
					continue
				terrains[layer][chunk.blocks[layer][x][y]].append(real_pos)

func press_circle(height_map: Array[Array], pos: Vector2i, radius: float) -> Array[Array]:
	for x in range(pos.x - int(radius) - 2, pos.x + int(radius) + 2):
		for y in range(pos.y - int(radius) - 2, pos.y + int(radius) + 2):
			#var delta = 
			if (pos - Vector2i(x, y)).length() < radius:
				height_map[x][y] *= 0.01
				
	return height_map

func generation_job():
	var iter = 1
	var cpos = Vector2i(0, 0)
	print("Generation job started")
	while (iter < 128):
		for i in range(iter):
			cpos += Vector2i(0, 1) 
			if superchunks_heightmaps.has(cpos):
				continue
			var hm = gen_height_map(cpos.x, cpos.y)
			superchunks_heightmaps[cpos] = hm
		
		for i in range(iter):
			cpos += Vector2i(1, 0) 
			if superchunks_heightmaps.has(cpos):
				continue
			var hm = gen_height_map(cpos.x, cpos.y)
			superchunks_heightmaps[cpos] = hm
		
		for i in range(iter + 1):
			cpos += Vector2i(0, -1) 
			if superchunks_heightmaps.has(cpos):
				continue
			var hm = gen_height_map(cpos.x, cpos.y)
			superchunks_heightmaps[cpos] = hm
		
		for i in range(iter + 1):
			cpos += Vector2i(-1, 0)
			if superchunks_heightmaps.has(cpos):
				continue
			var hm = gen_height_map(cpos.x, cpos.y)
			superchunks_heightmaps[cpos] = hm
		iter += 2
	print("Generation job finished")


func draw_sc(cpos: Vector2i):
	# superchunk generator job is hella fast
	drawn_scs.append(cpos)
	while (not superchunks_heightmaps.has(cpos)):
		continue
	var chunks = gen_chunks(superchunks_heightmaps[cpos], cpos.x, cpos.y)
	await draw_world(chunks)
	call_deferred("emit_signal", "superchunk_generated", cpos) 

func on_player_moved(pos: Vector2i):
	var removed_thread = false
	for i in range(-GENERATION_DISTANCE, GENERATION_DISTANCE + 1):
		for j in range(-GENERATION_DISTANCE, GENERATION_DISTANCE + 1):
			var sc = ((pos - Vector2i(32, 32)) / (SUPERCHUNK_SIZE * 16)) + Vector2i(i, j)
			if not (sc in drawn_scs):
				print("attemptint to draw superchunk: ", sc)
				var dt = Thread.new()
				var c = Callable(draw_sc)
				dt.start(c.bind(sc), Thread.PRIORITY_LOW)
				drawer_threads.append(dt)
	for t in drawer_threads:
		if not t.is_alive():
			t.wait_to_finish()
			drawer_threads.remove_at(drawer_threads.find(t))
			removed_thread = true
	if drawer_threads.is_empty() and removed_thread:
		rpnm()
