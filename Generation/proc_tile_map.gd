class_name ProcTileMap extends StratTileMap

@onready var sm: ProceduralStratMap = get_parent()
const OK = true
# Distrance in chunks at which chunks start generating
const VERBOSITY = 3
const GENERATION_DISTANCE = 1
const PATH_SAMPLE_SIZE = 100
const confs: Array[int] = [
	# symmetrical: o, x card, x diag
	0xAA, 0xBA, 0x155,
	# N-S: line, T's
	0x92, 0xB2, 0x9A, 0x11A,
	# E-W: line, T's
	0x38, 0xB8, 0x3A,
	# diag y
	0x11A, 0x072, 0x0B1, 0x09C,
	# vert y
	0x1A2, 0x11C, 0x095, 0x071,
	# lambda thin
	0x73, 0x56, 0xD4, 0x5C, 0x131, 0x119, 0x191, 0x113, 
	# lambda 
	0x154, 0x055, 0x115, 0x141 
]
const conf_masks = [0x1C0, 0x0C8, 0x049, 0x00B, 0x007, 0x026, 0x124, 0x1A0]

# you can't access the same layer from several threads
var tilemap_mutex: Mutex = Mutex.new()
var terrains: Array[Array]
var current_terrain_slot: int = 0

#@export var SEED = randi()
@export var SEED = 3453287850
@export var chunk_heightmaps: Dictionary = {}
@export var major_POIs: Dictionary = {}
@export var drawn_chunks: Array[Vector2i] = []
@export var superchunks_confs: Dictionary = {}

var drawn_chunks_mutex: Mutex = Mutex.new()
var major_poi_mutex: Mutex = Mutex.new()
var heightmap_mutex: Mutex = Mutex.new()

var drawer_semafore: Semaphore = Semaphore.new()
var gen_thread: Thread
var gen_queue_mutex: Mutex = Mutex.new()
var gen_queue: Array[Vector2i]

var major_POI_Reses: Dictionary = {
	0 : preload("res://Generation/POIs/spawn_poi.tscn"),
	1 : preload("res://Generation/POIs/simple_poi.tscn"),
}

# Vector 2i -> int
signal gen_queue_empty()

func get_superchunk_pos(cpos: Vector2i):
	return (cpos - Vector2i(2, 2)) / 3

func get_chunk_pos(real_pos: Vector2i):
	return (real_pos - Vector2i(Chunk.SIZE - 1, Chunk.SIZE - 1)) / Chunk.SIZE

func gen_world():
	if VERBOSITY >= 1: print(SEED)
	gen_heightmap(Vector2i(0, 0))
	var spawn_chunk_hm = chunk_heightmaps[Vector2i(0, 0)]
	chunk_heightmaps[Vector2i(0, 0)] = spawn_chunk_hm
	var spawn_poi: SpawnPOI = major_POI_Reses[0].instantiate()
	print(" - locking adding_children_mutex")
	add_child(spawn_poi)
	spawn_poi.place(Vector2i(0, 0))
	superchunks_confs[Vector2i(0, 0)] = 0xAA
	print(" - unlocking adding_children_mutex")
	var spawn_chunk: Chunk = gen_chunk(Vector2i(0, 0))
	major_POIs[Vector2i(0, 0)] = spawn_poi
	draw_chunk(spawn_chunk)
	mark_as_genned(Vector2i(0,0))

	gen_thread = Thread.new()
	gen_thread.start(gen_job, Thread.PRIORITY_LOW)
	# generate initial chunks
	on_player_moved(Vector2i(0, 0))
	sm.player.moved.connect(on_player_moved)
	await sm.player.nav_map_regenerated
	return OK

func verify_hm_genned(cpos):
	for i in range(-1, 2):
		for j in range(-1, 2):
			if not (cpos + Vector2i(i, j)) in chunk_heightmaps.keys():
				if VERBOSITY >= 4: print("gen_and_drawn_chunk: genning heightmap for ", cpos + Vector2i(i, j))
				gen_heightmap(cpos + Vector2i(i, j))

func gen_job():
	while (true):
		if VERBOSITY >= 2: print("gen_job: waiting at semafore")
		drawer_semafore.wait()
		if VERBOSITY >= 2: print("gen_job: staring to work")
		
		var threads: Array[Thread] = []
		while (gen_queue.is_empty() == false):
			print(" - locking gen_queue_mutex")
			gen_queue_mutex.lock()
			var cpos = gen_queue.pop_front()
			mark_as_genned(cpos)
			print(" - unlocking gen_queue_mutex")
			gen_queue_mutex.unlock()
			if VERBOSITY >= 3: print("gen_and_drawn_chunk: generating ", cpos)
			
			verify_hm_genned(cpos)
			await get_tree().process_frame 
			# 9 bit number
			var conf: int
			var scpos = get_superchunk_pos(cpos) 
			if not scpos in superchunks_confs: 
				var nconf = get_nconf(scpos)
				conf = select_conf(nconf)
				superchunks_confs[scpos] = conf
			else:
				conf = superchunks_confs[scpos]
			if VERBOSITY >= 3: print("gen_and_drawn_chunk: checking for pois to place")
			place_pois_in_sc(scpos, conf)
			if VERBOSITY >= 3: print("gen_and_drawn_chunk: done placing POIs")
			# connectiong poi in called chunk to neibouring pois
			if major_POIs.get(cpos, false):
				for i in range(9):
					if i == 4: continue
					var rcpos = cpos + Vector2i(i / 3 - 1, i % 3 - 1)
					if not major_POIs.get(rcpos, false):
						continue
					if VERBOSITY >= 4: print("gen_and_drawn_chunk: connectiong pois at ", cpos, " and ", rcpos)
					connect_poi(major_POIs[cpos], major_POIs[rcpos], 3)
			if VERBOSITY >= 3: print("gen_and_drawn_chunk: done connectiong POI")
			var chunk: Chunk = gen_chunk(cpos)
			draw_chunk(chunk)
		if VERBOSITY >= 1: print("gen_job: finalizing")
		call_deferred("finalize_gen")
	return OK

func gen_heightmap(cpos: Vector2i):
	"""
	generates terrain heightmap of the chunk
	it will be modified later be gen_poi, gen_path, etc.
	"""
	if VERBOSITY >= 2: print("gen_heightmap(", cpos, ")")
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
	print(" - locking heightmap_mutex")
	heightmap_mutex.lock()
	chunk_heightmaps[cpos] = height_map
	print(" - unlocking heightmap_mutex")
	heightmap_mutex.unlock()

var possible_POI: Array[PackedScene] = [
	preload("res://Generation/POIs/SimplePOIs/extermnal_puzzle_poi.tscn"),
]

func place_poi(cpos: Vector2i, poi: ProcMapPOI):
	"""
	generates major POI and adds it to major_POIs[cpos]
	modifies chunk_heightmaps[cpos]
	"""
	if VERBOSITY >= 3: print("place_poi(", cpos, ", ", poi, ")")
	print(" - locking heightmap_mutex")
	heightmap_mutex.lock()
	add_child(poi)
	poi.place(cpos)
	major_POIs[cpos] = poi
	print(" - unlocking heightmap_mutex")
	heightmap_mutex.unlock()

func gen_chunk(cpos: Vector2i) -> Chunk:
	if VERBOSITY >= 1: print("gen_chunk(", cpos, ")")
	var chunk: Chunk = Chunk.create(cpos, chunk_heightmaps[cpos][cpos.x][cpos.y])
	print(" - locking heightmap_mutex")
	heightmap_mutex.lock()
	var heightmap: Array[Array] = chunk_heightmaps[cpos]
	print(" - unlocking heightmap_mutex")
	heightmap_mutex.unlock()
	for x in range(Chunk.SIZE):
		for y in range(Chunk.SIZE):
			var layer = int(heightmap[x][y])
			layer = int(layer)
			for lid in range(1, min(layer, 5)):
				chunk.blocks[lid][x][y] = 8
	return chunk

func get_nconf(scpos: Vector2i) -> int:
	if VERBOSITY >= 10: print("select_conf(", scpos, ")")
	var nconf: int = 0
	var c = 0
	for i in range(9):
		if i == 4:
			continue
		c  += 1
		if not scpos + Vector2i(i / 3 - 1, i % 3 + 1) in superchunks_confs: 
			continue
		if superchunks_confs[scpos + Vector2i(i / 3 - 1, i % 3 + 1)] ^ conf_masks[c]:
			nconf += 1
		nconf = nconf << 1
	return nconf

func select_conf(nconf: int):
	if VERBOSITY >= 10: print("select_conf(", nconf, ")")
	var max_score = 0
	var best_matches = []
	for conf in confs:
		var conn: int = conf & nconf
		var mask: int = 1
		var score: int = 0
		for i in range(9):
			score += int((conn ^ mask) > 0)
			mask = mask << 1
		
		if score == max_score:
			best_matches.append(conf)
		elif score > max_score:
			max_score = score
			best_matches = [conf]
	return best_matches.pick_random()

func place_pois_in_sc(scpos: Vector2i, conf: int):
	if VERBOSITY >= 10: print("place_pois_in_sc(", scpos, ", ", conf, ")")
	var pos_mask = 0x100
	for i in range(9):
		if not (3 * scpos + Vector2i(i / 3, i % 3)) in chunk_heightmaps.keys():
			if VERBOSITY >= 10: print("gen_and_drawn_chunk: genning heightmap for ", 3 * scpos + Vector2i(i / 3, i % 3))
			gen_heightmap(3 * scpos + Vector2i(i / 3, i % 3))
		
		var has_poi = conf & pos_mask
		pos_mask = pos_mask >> 1
		if not has_poi:
			continue
		var poi_cpos = 3 * scpos + Vector2i(i / 3, i % 3)
		if major_POIs.get(poi_cpos, false):
			continue
		if VERBOSITY >= 4: print("place_pois_in_sc: placing POI at ", poi_cpos)
		var poi: ProcMapPOI = possible_POI.pick_random().instantiate()
		call_deferred("place_poi", poi_cpos, poi)
	await get_tree().process_frame 
	return OK

func connect_poi(poi1: ProcMapPOI, poi2: ProcMapPOI, prad: float):
	if VERBOSITY >= 10: print("connect_poi(", poi1, ", ", poi2, ", ", prad, ")")
	var curve = Curve2D.new()
	var rpos1 = poi1.chunk_pos + poi1.poi_pos
	var rpos2 = poi2.chunk_pos + poi2.poi_pos
	var ctrlp = Vector2(randi_range(rpos1.x, rpos2.x), randi_range(rpos1.y, rpos2.y))
	for i in range(PATH_SAMPLE_SIZE):
		var t = float(i) / PATH_SAMPLE_SIZE
		var p1 = rpos1 * (1 - t) + ctrlp * t 
		var p2 = ctrlp * (1 - t) + rpos2 * t 
		var p3 = p1 * (1 - t) + p2 * t 
		curve.add_point(p3)
	#var 
	print(" - locking heightmap_mutex")
	heightmap_mutex.lock()
	for p in curve.tessellate_even_length():
		var ipos = Vector2i(p)
		var cpos = get_chunk_pos(ipos) 
		chunk_heightmaps[cpos] = press_circle(chunk_heightmaps[cpos], ipos, prad)
		# the corner case
		for i in range(4):
			if (ipos % Chunk.SIZE - Vector2i(i / 2, i % 2) * Chunk.SIZE).length() < 2:
				var pid =(Vector2i(i / 2, i % 2) * 2) - Vector2i(-1, -1)
				var ppid = Vector2i(-pid.x, pid.y)
				chunk_heightmaps[cpos + pid] = press_circle(chunk_heightmaps[cpos], Vector2i(32, 32) - 32 * pid, prad - 1)
				chunk_heightmaps[cpos + Vector2i(pid.x, 0)] = press_circle(chunk_heightmaps[cpos], Vector2i(32, 32) - 32 * ppid, prad - 1)
				chunk_heightmaps[cpos + Vector2i(0, pid.y)] = press_circle(chunk_heightmaps[cpos], Vector2i(32, 32) + 32 * ppid, prad - 1)
	print(" - unlocking heightmap_mutex")
	heightmap_mutex.unlock()
	return OK

func draw_chunk(chunk: Chunk):
	"""
	can be called assinchronously 
	sets terrains in tilemap for given chunk
	the slow part is set_cells_terrain_connect
	only one thread can modify one layer at a time
	"""
	if VERBOSITY >= 2: print("draw_chunk ", chunk.pos, ": ", "starting drawing chunk ", chunk.pos)
	print(" - locking tilemap_mutex")
	tilemap_mutex.lock()
	if chunk.pos == Vector2i(1, -1):
		print("")
	if VERBOSITY >= 3: print("draw_chunk ", chunk.pos, ": ", "captured terrain")
	terrains.clear()
	terrains = chunk.get_terrains()
	if VERBOSITY >= 3: print("draw_chunk ", chunk.pos, ": ", "loaded chunk")
	var threads: Array[Thread] = []
	for layer in range(Chunk.LAYER_COUNT):
		var c = draw_layer
		c = c.bind(layer)
		var t: Thread = Thread.new()
		t.start(c, Thread.PRIORITY_LOW)
		threads.append(t)
	if VERBOSITY >= 3: print("draw_chunk ", chunk.pos, ": ", "dispatched threads")
	
	var cp = chunk.pos * Chunk.SIZE 
	var border: Array[Array] = [[],[],[],[]]
	for i in range(Chunk.SIZE):
		sm.tilemap.set_cell(0, cp + Vector2i(i, 0), 0, 
			Vector2i(randi_range(0, 2), randi_range(0, 1)))
		sm.tilemap.set_cell(0, cp + Vector2i(0, i), 0, 
			Vector2i(randi_range(0, 2), randi_range(0, 1)))
		sm.tilemap.set_cell(0, cp + Vector2i(Chunk.SIZE, i), 0, 
			Vector2i(randi_range(0, 2), randi_range(0, 1)))
		sm.tilemap.set_cell(0, cp + Vector2i(i, Chunk.SIZE), 0, 
			Vector2i(randi_range(0, 2), randi_range(0, 1)))
	for t in threads:
		t.wait_to_finish()
	threads.clear()
	if VERBOSITY >= 3: print("draw_chunk ", chunk.pos, ": ", "done drawing")
	print(" - unlocking tilemap_mutex")
	tilemap_mutex.unlock()
	if VERBOSITY >= 3: print("---------------------------------")
	return OK

func draw_layer(layer: int):
	if VERBOSITY >= 10: print("draw_layer(", layer, ")")
	for terrain_id in range(14):
		set_cells_terrain_connect(layer, 
		terrains[layer][terrain_id], terrain_id / 8, terrain_id % 8, true)
	return OK

func press_circle(height_map: Array[Array], pos: Vector2i, radius: float) -> Array[Array]:
	"""
	makes a cirle of flat terrain at height 0 that gradually transitions to normal terrain
	works within a chunk
	DOES NOT change `chunk_heightmaps`
	
	 - height_map - height map of a chunk
	 - pos - local position
	 - radius
	"""
	if VERBOSITY >= 10: print("press_circle(hm", ", ", pos, ", ", radius, ")")
	for x in range(min(0,(pos.x - int(radius) * 2)), 
				min(Chunk.SIZE, pos.x + int(radius) * 2)):
		for y in range(pos.y - int(radius) - 5, pos.y + int(radius) + 5):
			if (pos - Vector2i(x, y)).length() < radius:
				height_map[x][y] *= 0
			elif (pos - Vector2i(x, y)).length() < radius * 2:
				height_map[x][y] *= ((pos - Vector2i(x, y)).length() - radius) ** 2
				
	return height_map

func mark_as_genned(cpos: Vector2i):
	if VERBOSITY >= 3: print("mark_as_genned(", cpos, ")")
	print(" - locking drawn_chunks_mutex")
	drawn_chunks_mutex.lock()
	drawn_chunks.append(cpos)
	print(" - unlocking drawn_chunks_mutex")
	drawn_chunks_mutex.unlock()

func regen_navmap():
	if VERBOSITY >= 3: print("regen_navmap()")
	sm.player.regen_nav()

func check_genned(cpos):
	if VERBOSITY >= 10: print("check_genned(", cpos, ")")
	print(" - locking gen_queue_mutex")
	gen_queue_mutex.lock()
	if not (cpos in drawn_chunks or cpos in gen_queue):
		if VERBOSITY >= 10: print("on_player_moved: queued to draw: ", cpos)
		gen_queue.append(cpos)
		if gen_queue.size() == 1:
			if VERBOSITY >= 10: print("on_player_moved: posting to gen semafore")
			drawer_semafore.post()
	print(" - unlocking gen_queue_mutex")
	gen_queue_mutex.unlock()
	

func on_player_moved(pos: Vector2i):
	if not (pos.x % 16 == 0 or pos.y % 16 == 0): 
		return
	if VERBOSITY >= 10: print("on_player_moved(", pos, ")")
	# +x +y
	for i in range(0, GENERATION_DISTANCE + 1):
		for j in range(0, GENERATION_DISTANCE + 1):
			check_genned(get_chunk_pos(pos) + Vector2i(i, j))
	# -x +y
	for i in range(0, -GENERATION_DISTANCE - 1, -1):
		for j in range(-GENERATION_DISTANCE, GENERATION_DISTANCE + 1):
			check_genned(get_chunk_pos(pos) + Vector2i(i, j))
	# +x -y
	for i in range(0, GENERATION_DISTANCE + 1):
		for j in range(0, -GENERATION_DISTANCE - 1, -1):
			check_genned(get_chunk_pos(pos) + Vector2i(i, j))
	# -x -y
	for i in range(0, -GENERATION_DISTANCE - 1, -1):
		for j in range(0, -GENERATION_DISTANCE - 1, -1):
			check_genned(get_chunk_pos(pos) + Vector2i(i, j))

func finalize_gen():
	if VERBOSITY >= 3: print("finalize_gen()")
	print(" - locking tilemap_mutex")
	tilemap_mutex.lock()
	regen_navmap()
	for layer in range(Chunk.LAYER_COUNT):
		set_layer_enabled(layer, false)
		notify_runtime_tile_data_update(layer)
		update_internals()
		set_layer_enabled(layer, true)
	if VERBOSITY >= 10: print("reloaded layers")
	print(" - unlocking tilemap_mutex")
	tilemap_mutex.unlock()
