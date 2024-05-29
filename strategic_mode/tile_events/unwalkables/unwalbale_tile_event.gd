class_name UnwalkableTileEvent extends TileEvent

"""
unwalkable tile event
snaps to the closest tile and makes it unwalkable

"""


@onready var game: Game = get_tree().root.get_child(0)
@onready var strat_map: StratMap = game.strat_map
var map_pos: Vector2i


func snap_to_grid():
	var tilemap: TileMap = strat_map.tilemap
	map_pos = tilemap.local_to_map(global_position)
	global_position = tilemap.map_to_local(map_pos)
	strat_map.player.nav_map_regenerated.connect(update_state)

func update_state():
	strat_map.tilemap.set_walkable(map_pos, false)

func _ready():
	assert(texture != null, "no texture")
	sprite.texture = texture
	strat_map.strat_map_loaded.connect(snap_to_grid)
	
	
func activate():
	pass
