class_name Chunk extends Resource

const LAYER_COUNT: int = 5
const SIZE: int = 64
const TERRAINS_COUNT: int = 14
# position of chunk in the world
var pos: Vector2i
# array[array[array[vector2i]]] where vector2i -- position on the tile atlas
# coords go as `layer`, `x`, `y`
# by defaul it's ground on Terrain0 and air on other
var blocks: Array[Array] = []

func get_pos(rpos: Vector2i) -> Vector2i:
	return rpos + pos * Chunk.SIZE

func rpos(x: int, y: int) -> Vector2i:
	return Vector2i(x, y) + pos * Chunk.SIZE

static func create(pos: Vector2i, SEED: int) -> Chunk:
	var c: Chunk = Chunk.new()
	c.pos = pos
	c.blocks.append([])
	for i in range(SIZE):
		var row = []
		for j in range(SIZE):
			row.append(0)
		c.blocks[0].append(row)
	for l in range(1, LAYER_COUNT):
		var layer = []
		for i in range(SIZE):
			var row = []
			for j in range(SIZE):
				row.append(-1)
			layer.append(row)
		c.blocks.append(layer)
	return c 

func get_layer_terrains(layer: int) -> Array[Array]:
	var terrains: Array[Array] = [[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
	for i in range(SIZE):
		for j in range(SIZE):
			if blocks[layer][i][j] == -1: continue
			terrains[blocks[layer][i][j]].append(rpos(i, j))
	return terrains

func get_terrains() -> Array[Array]:
	var terrains: Array[Array] = []
	for layer in range(Chunk.LAYER_COUNT):
		print("collecting layer ", layer)
		terrains.append(get_layer_terrains(layer))
	return terrains
