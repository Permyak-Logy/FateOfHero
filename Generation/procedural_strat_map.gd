class_name ProceduralStratMap extends StratMap 


# size of the world in chunks
const WORLD_SIZE = 16
# array[array[array[Vector2i]]] indexed as layer_id, terrain_id, tile_id
var terrains: Array[Array]
#array[array[chunk]]
var chunks: Array[Array]

func gen_world():
	init_chunks()
	gen_chunks()
	draw_world()

func _ready():
	gui.gui_opened.connect(on_gui_opened)
	gui.gui_closed.connect(on_gui_closed)
	gen_world()
	strat_map_loaded.emit()

func init_chunks():
	chunks = []
	for x in range(WORLD_SIZE):
		chunks.append([])
		for y in range(WORLD_SIZE):
			var chunk = Chunk.new()
			chunk.pos = Vector2i(x - (WORLD_SIZE / 2), y - (WORLD_SIZE / 2))
			chunks[x].append(chunk)

func gen_chunks():
	var noise_gen = FastNoiseLite.new()
	var noise_image: Image = noise_gen.get_image(WORLD_SIZE * 16, WORLD_SIZE * 16)
	var mrx = 0
	var mry = 0
	var noise = noise_image.get_data()
	for i in range(WORLD_SIZE):
		for j in range(WORLD_SIZE):
			var chunk: Chunk = chunks[i][j]
			for x in range(16):
				for y in range(16):
					var rx = 16 * i + x
					var ry = 16 * j + y
					if rx > mrx: mrx = rx 
					if ry > mry: mry = ry 
					var layer = noise[ry * WORLD_SIZE * 16 + rx]
					layer = layer / 64
					for lid in range(1, min(layer, 5)):
						chunk.blocks[lid][x][y] = 8
	print("reaced: ", mrx, " ", mry)
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
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
	for x in range(WORLD_SIZE):
		for y in range(WORLD_SIZE):
			load_chunk(chunks[x][y])
	for layer in range(5):
		for terrain_id in range(14):
			tilemap.set_cells_terrain_connect(layer, terrains[layer][terrain_id], terrain_id / 8, terrain_id % 8)

func load_chunk(chunk: Chunk):
	for layer in range(min(5, chunk.blocks.size())):
		for x in range(16):
			for y in range(16):
				var real_pos = 16 * chunk.pos + Vector2i(x, y)
				if chunk.blocks[layer][x][y] == -1:
					continue
				terrains[layer][chunk.blocks[layer][x][y]].append(real_pos)
