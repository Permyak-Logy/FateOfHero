class_name Chunk extends Resource

const LAYER_COUNT: int = 5
const SIZE: int = 64
# position of chunk in the world
var pos: Vector2i
# array[array[array[vector2i]]] where vector2i -- position on the tile atlas
# coords go as `layer`, `x`, `y`
# by defaul it's ground on Terrain0 and air on other
var blocks: Array[Array] = []

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
