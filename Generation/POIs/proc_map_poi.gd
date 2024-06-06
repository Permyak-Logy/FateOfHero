class_name ProcMapPOI extends Node2D
 
# if poi_pos != null, ignore poi range
@export_category("things to save; do not modify")
@export var poi_pos: Vector2i
@export var chunk_pos: Vector2i

@onready var tilemap: ProcTileMap = $".."
@onready var strat_map: ProceduralStratMap = $"../.."

func place(pos: Vector2i):
	assert(false, "redefine place")
	pass
