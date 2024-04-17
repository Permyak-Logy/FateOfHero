extends Node2D

class_name Game
@onready var strat_map: StratMap = load("res://stategic_mode/strat_map.tscn").instantiate()
@onready var tactical_map: TacticalMap = load("res://tactical_mode/tactical_map.tscn").instantiate() 
@onready var city_map: CityMap = load("res://city_mode/CityMap.tscn").instantiate()
@onready var external_puzzle_container: ExternalPuzzleContainer = \
load("res://external_puzzles/external_puzzle_container.tscn").instantiate()

var active_scene = null

func _ready():
	add_child(strat_map)
	active_scene = strat_map

func activate(scene: Node):
	remove_child(active_scene)
	active_scene = scene
	add_child(scene)

func deactivate(scene: Node):
	remove_child(scene)

func to_tact_mode():
	activate(tactical_map)
	
func to_strat_mode():	
	activate(strat_map)
	
func to_city_mode():	
	activate(city_map)

func to_puzzle_mode():
	activate(external_puzzle_container)	
