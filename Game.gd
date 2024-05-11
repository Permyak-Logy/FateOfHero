class_name Game extends Node2D

@onready var strat_map: StratMap 
@onready var tactical_map: TacticalMap = load("res://tactical_mode/tactical_map.tscn").instantiate() 
@onready var city_container: CityContainer = load("res://city_mode/city_container.tscn").instantiate()
@onready var external_puzzle_container: ExternalPuzzleContainer = \
load("res://external_puzzles/external_puzzle_container.tscn").instantiate()
@onready var main_menu: MainMenu = load("res://GUI/main_menu/main_menu.tscn").instantiate()
@onready var StratMapRes = preload("res://strategic_mode/strat_map.tscn")


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

func save():
	var packed: PackedScene = PackedScene.new()
	if ResourceLoader.exists("save/save.tscn"):
		remove_save()
	packed.pack(strat_map)
	ResourceSaver.save(packed, "save/save.tscn")
	ResourceSaver.save(strat_map.player.inventory, "save/player_inventory.tres")

func remove_save():
	if not ResourceLoader.exists("save.tscn"):
		return 
	var dir = DirAccess.open("res://save")
	dir.remove("save.tscn")

func load_save():
	strat_map = ResourceLoader.load("res://save/save.tscn").instantiate()
	add_child(strat_map)
	strat_map.player.inventory = ResourceLoader.load("save/player_inventory.tres")
	remove_child(strat_map)

func new_save():
	strat_map = StratMapRes.instantiate()
