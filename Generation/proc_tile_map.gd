class_name ProcTileMap extends StratTileMap

@onready var sm: ProceduralStratMap = get_parent()
# size of the world in chunks
const WORLD_SIZE = 4
# array[array[array[Vector2i]]] indexed as layer_id, terrain_id, tile_id
var terrains: Array[Array]
#array[array[chunk]]
var chunks: Array[Array]

# Array[Array[float]];  height_map of the sampled world
var height_map: Array[Array] = []

func gen_world():
	init_chunks()
	gen_height_map()
	gen_chunks()
	draw_world()

func init_chunks():
	chunks = []
	for x in range(WORLD_SIZE):
		chunks.append([])
		for y in range(WORLD_SIZE):
			var chunk = Chunk.new()
			chunk.pos = Vector2i(x - (WORLD_SIZE / 2), y - (WORLD_SIZE / 2))
			chunks[x].append(chunk)

func gen_height_map():
	var noise_gen = FastNoiseLite.new()
	noise_gen.noise_type = FastNoiseLite.TYPE_PERLIN
	noise_gen.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise_gen.frequency = 0.03
	noise_gen.seed = randi()
	
	var noise_gen_2 = FastNoiseLite.new()
	noise_gen_2.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise_gen_2.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise_gen_2.frequency = 0.015
	noise_gen_2.seed = randi()
	
	sm.noise_img.texture = ImageTexture.create_from_image(noise_gen.get_image(WORLD_SIZE * 16, WORLD_SIZE * 16))
	for i in range(WORLD_SIZE * 16):
		height_map.append([])
		for j in range(WORLD_SIZE * 16):
			var v1 = abs(noise_gen.get_noise_2d(i, j))
			var v2 = noise_gen_2.get_noise_2d(i, j)
			var val = v1 * 1 + v2 *  2
			val = abs(val * 3)
			height_map[i].append(val)
	#print(height_map)

func gen_chunks():
	var mrx = 0
	var mry = 0
	for i in range(WORLD_SIZE):
		for j in range(WORLD_SIZE):
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

func draw_world():
	terrains = [
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []],
		[[], [], [], [], [], [], [], [], [], [], [], [], [], []]
	]
	for x in range(-16 * WORLD_SIZE/2 - 16, 16 * WORLD_SIZE / 2 + 17):
		for y in range(-16 * WORLD_SIZE/2 - 16, 16 * WORLD_SIZE / 2 + 17):
			set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
	for x in range(WORLD_SIZE):
		for y in range(WORLD_SIZE):
			load_chunk(chunks[x][y])
	var threads: Array[Thread] = []
	for layer in range(5):
			var c = draw_chunk
			c = c.bind(layer)
			var t: Thread = Thread.new()
			t.start(c, Thread.PRIORITY_NORMAL)
			threads.append(t)
	for t in threads:
		t.wait_to_finish()

func draw_chunk(layer: int):
	for terrain_id in range(14):
		set_cells_terrain_connect(layer, terrains[layer][terrain_id], terrain_id / 8, terrain_id % 8)

func load_chunk(chunk: Chunk):
	for layer in range(min(5, chunk.blocks.size())):
		for x in range(16):
			for y in range(16):
				var real_pos = 16 * chunk.pos + Vector2i(x, y)
				if chunk.blocks[layer][x][y] == -1:
					continue
				terrains[layer][chunk.blocks[layer][x][y]].append(real_pos)
