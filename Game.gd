class_name Game extends Node2D

@onready var strat_map: StratMap
@onready var tactical_map: TacticalMap = load("res://tactical_mode/tactical_map.tscn").instantiate() 
@onready var city_container: CityContainer = load("res://city_mode/city_container.tscn").instantiate()
@onready var external_puzzle_container: ExternalPuzzleContainer = \
load("res://external_puzzles/external_puzzle_container.tscn").instantiate()
@onready var main_menu: MainMenu = load("res://GUI/main_menu/main_menu.tscn").instantiate()
var StratMapRes = preload("res://strategic_mode/strat_map.tscn")
var ProceduralSMRes = preload("res://Generation/procedural_strat_map.tscn")

var active_scene = null

func _ready():
	add_child(main_menu)
	active_scene = main_menu

func activate(scene: Node):
	if active_scene:
		if active_scene == strat_map:
			strat_map.visible = false
			strat_map.pause()
		else:
			remove_child(active_scene)
	active_scene = scene
	if scene == strat_map:
		strat_map.visible = true
	else:
		add_child(scene)

func to_tact_mode():
	activate(tactical_map)
	
func to_strat_mode():
	activate(strat_map)
	
func to_city_mode():
	activate(city_container)

func to_puzzle_mode():
	activate(external_puzzle_container)

func to_main_menu():
	main_menu.update()
	activate(main_menu)

func save():
	var packed: PackedScene = PackedScene.new()
	remove_save()
	packed.pack(strat_map)
	DirAccess.make_dir_absolute("save")
	ResourceSaver.save(packed, "save/save.tscn")
	ResourceSaver.save(strat_map.player.inventory, "save/player_inventory.tres")
	for scn in get_tree().get_nodes_in_group("MicroInventoryOwner"):
		if not scn.local_inventory:
			continue
		ResourceSaver.save(scn.local_inventory, "save/" + scn.name + "_inv.tres")
	for scn in get_tree().get_nodes_in_group("InventoryOwner"):
		if not scn.local_inventory:
			continue
		ResourceSaver.save(scn.local_inventory, "save/" + scn.name + "_inv.tres")


func remove_save():
	if not DirAccess.dir_exists_absolute("res://save"):
		return
	
	var dir = DirAccess.open("res://save")
	for file in dir.get_files():
		dir.remove(file)
	DirAccess.remove_absolute("res://save")

func load_save():
	print(" # Loading game")
	print("loading: ", "[res://save/save.tscn]")
	strat_map = load("res://save/save.tscn").instantiate()
	add_child(strat_map)
	strat_map.player.inventory = ResourceLoader.load("save/player_inventory.tres")
	strat_map.player.sprite.hframes = 8
	for scn in get_tree().get_nodes_in_group("MicroInventoryOwner"):
		if not ResourceLoader.exists("res://save/" + scn.name + "_inv.tres"):
			continue
		print("loading: [", "res://save/" + scn.name + "_inv.tres", "]")
		var inv = load("res://save/" + scn.name + "_inv.tres")
		scn.set_inventory(inv)
	
	for scn in get_tree().get_nodes_in_group("InventoryOwner"):
		if not ResourceLoader.exists("res://save/" + scn.name + "_inv.tres"):
			continue
		print("loading: [", "res://save/" + scn.name + "_inv.tres", "]")
		var inv = load("res://save/" + scn.name + "_inv.tres")
		scn.set_inventory(inv)
	remove_child(strat_map)

func new_save(init_char: PackedScene):
	strat_map = StratMapRes.instantiate()
	add_child(strat_map)
	strat_map.player.inventory.characters = [init_char]
	var char = init_char.instantiate()
	strat_map.player.sprite.texture = strat_map.player.texture[char.name]
	strat_map.player.sprite.hframes = 8
	strat_map.player.mc_name = char.name
	remove_child(strat_map)

func new_procedural_world(init_char: PackedScene):
	var sm: ProceduralStratMap = ProceduralSMRes.instantiate()
	add_child(sm)
	sm.player.inventory.characters = [init_char]
	var char = init_char.instantiate()
	
	sm.player.sprite.texture = sm.player.texture[char.name]
	sm.player.sprite.hframes = 8
	sm.player.mc_name = char.name
	#sm.player.move_to(Vector2i(Chunk.SIZE / 2, Chunk.SIZE / 2))
	sm.tilemap.gen_world()
	sm.strat_map_loaded.emit()
	strat_map = sm
	to_strat_mode()
