class_name StealthObstacle extends Node2D

@onready var tilemap: TileMap = get_parent()
var pos: Vector2i

func set_unsafe(target_pos: Vector2i):
	tilemap.set_cell(0, target_pos, 0, Vector2i(0, 0)) 

func set_unwalkable(target_pos: Vector2i):
	tilemap.set_cell(0, target_pos, 0, Vector2i(2, 0)) 

# must be redefined 
func place(pos_: Vector2i):
	assert(false, "! redefine place for " + str(self))
