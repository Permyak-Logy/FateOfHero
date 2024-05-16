class_name TimedGateTileEvent extends GateTileEvent 

"""
will open when `update_time(time)` is called with values  
"""

@export var open_time_start: int = 0
@export var open_time_end: int = 120


func _ready():
	assert(0 <= open_time_start)
	assert(open_time_start < open_time_end)
	assert(open_time_end < 1440)
	strat_map.time_changed.connect(update_time)
	strat_map.strat_map_loaded.connect(snap_to_grid)
	
func update_time(time: int):
	if open_time_start <= time and time <= open_time_end:
		open()
	else:
		close()
