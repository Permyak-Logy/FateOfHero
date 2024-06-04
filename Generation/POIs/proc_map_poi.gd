class_name ProcMapPOI extends Node2D
 
@export_category("POI settings")
@export var poi_range_x: Vector2i
@export var poi_range_y: Vector2i
@export var radius: int 
# if poi_pos != null, ignore poi range
@export_category("things to save")
@export var poi_pos: Vector2i
@export var chunk_pos: Vector2i

@onready var tilemap: ProcTileMap = get_parent()
@onready var strat_map: ProceduralStratMap = get_parent().get_parent()

func place(pos: Vector2i):
	assert(false, "redefine place")
	pass
