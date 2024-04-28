extends "res://strategic_mode/tile_events/gate.gd"

@export var open_time_start: int = 0
@export var open_time_end: int = 120

@onready var strat_map: StratMap = get_tree().root.get_child(0).strat_map

func _ready():
	strat_map.time_changed.connect(update_time)
	pass
	
func update_time(time: int):
	if open_time_start <= time and time <= open_time_end:
		open()
	else:
		close()
