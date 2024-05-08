extends "res://strategic_mode/tile_events/unwalkables/unwalbale_tile_event.gd"

@onready var collider: CollisionShape2D = $EventCollider

func _ready():
	strat_map.strat_map_loaded.connect(snap_to_grid)

func open():
	strat_map.tilemap.set_walkable(map_pos, true)
	sprite.frame = 1

func close():
	strat_map.tilemap.set_walkable(map_pos, false)
	sprite.frame = 0

func activate():
	pass
