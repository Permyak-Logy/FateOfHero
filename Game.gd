extends Node2D

class_name Game
@onready var strat_map: StratMap = load("res://stategic_mode/strat_map.tscn").instantiate()
@onready var tactical_map: TacticalMap = load("res://tactical_mode/tactical_map.tscn").instantiate() 

func _ready():
	add_child(strat_map)
	pass
	
func activate(scene: Node):
	add_child(scene)
	
func deactivate(scene: Node):
	remove_child(scene)

func to_tact_mode():
	deactivate(strat_map)
	activate(tactical_map)
	
func to_strat_mode():
	deactivate(tactical_map)
	
	activate(strat_map)
	
