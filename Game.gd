class_name Game extends Node2D

@onready var strat_map: StratMap 
@onready var tactical_map: TacticalMap = load("res://tactical_mode/tactical_map.tscn").instantiate() 
@onready var city_container: CityContainer = load("res://city_mode/city_container.tscn").instantiate()
@onready var external_puzzle_container: ExternalPuzzleContainer = \
load("res://external_puzzles/external_puzzle_container.tscn").instantiate()
@onready var main_menu: MainMenu = load("res://GUI/main_menu/main_menu.tscn").instantiate()

var active_scene = null

func _ready():
	add_child(main_menu)
	active_scene = main_menu

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
	activate(city_container)

func to_puzzle_mode():
	activate(external_puzzle_container)

func to_main_menu():
	activate(main_menu)
