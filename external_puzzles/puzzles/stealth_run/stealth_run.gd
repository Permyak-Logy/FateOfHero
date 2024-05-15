class_name StealthRun extends BasePuzzle

@onready var tilemap: TileMap = $TileMap
@onready var player: StealthPlayer = $StealthPlayer
@onready var game: Game = get_tree().root.get_child(0)
@onready var inventory: Inventory = game.strat_map.player.inventory
var field_size: Vector2i = Vector2i(20, 15)

var CampfireRes: PackedScene = preload("res://external_puzzles/puzzles/stealth_run/obstacles/campfire.tscn")
var TreeRes: PackedScene = preload("res://external_puzzles/puzzles/stealth_run/obstacles/tree.tscn")
var TentRes: PackedScene = preload("res://external_puzzles/puzzles/stealth_run/obstacles/tent.tscn")
var EnemyRes: PackedScene = preload("res://external_puzzles/puzzles/stealth_run/obstacles/stealth_enemy.tscn")
var EPWinConditionRes: PackedScene = preload("res://external_puzzles/puzzles/safe_path/win_condition_point.tscn")

var enemies: Array[PackedScene]
var enemy_level: int
var pawns: Array[StealthEnemy] = []
var trees: Array[StealthTree] = []
var wc: EPWinCondition = EPWinConditionRes.instantiate()
var wc_reached: bool = false

func dist(a: Vector2i, b: Vector2i) -> int:
	return max(abs(a.x - b.x), abs(a.y - b.y))

func gen_field():
	var rng = RandomNumberGenerator.new()
	var campfire: StealthCampfire = CampfireRes.instantiate()
	tilemap.add_child(campfire)
	campfire.place(Vector2i(randi_range(8 , 12), randi_range(10 , 12)))
	
	var ci: StealthEnemy = EnemyRes.instantiate()
	add_child(ci)
	ci.place(campfire.pos + Vector2i(0, -2), StealthEnemy.Direction.South)
	pawns.append(ci)
	
	ci = EnemyRes.instantiate()
	add_child(ci)
	ci.place(campfire.pos + Vector2i(-2, 0), StealthEnemy.Direction.East)
	pawns.append(ci)
	
	ci = EnemyRes.instantiate()
	add_child(ci)
	ci.place(campfire.pos + Vector2i(2, 0), StealthEnemy.Direction.West)
	pawns.append(ci)
	
	var tents: Array[StealthTent] = []
	var tc = 0
	for i in range(6):
		var tent: StealthTent = TentRes.instantiate()
		var pos = Vector2i(randi_range(6, 16), randi_range(3, 9))
		var ok = true
		if dist(pos, campfire.pos) < 6:
			ok = false
			
		for other in tents:
			if dist(pos, other.pos)< 6:
				ok = false
				break
		if not ok:
			continue
		tc += 1
		if tc > 2:
			break
		var dir = Vector2(campfire.pos - pos).normalized()
		if abs(dir.x) > abs(dir.y):
			if dir.x > 0:
				tent.dir = StealthTent.Direction.East
			else:
				tent.dir = StealthTent.Direction.West
		else:
			if dir.y > 0:
				tent.dir = StealthTent.Direction.South
			else:
				tent.dir = StealthTent.Direction.North
		print(dir)
		print(tent.dir)
		tilemap.add_child(tent)
		tent.place(pos)
		tents.append(tent)
	
	if tc == 0:
		print("forced a tent")
		var tent = TentRes.instantiate()
		tilemap.add_child(tent)
		tent.dir = tent.Direction.South
		tent.place(campfire.pos + Vector2i(5, -1))
		tents.append(tent)
	add_child(wc)
	var tid = randi_range(0, tents.size() - 1)
	var wc_pos = tents[tid].pos
	if tents[tid].dir == StealthTent.Direction.North:
		wc.global_position = tilemap.map_to_local(wc_pos + Vector2i(0, 1))
	if tents[tid].dir == StealthTent.Direction.South:
		wc.global_position = tilemap.map_to_local(wc_pos + Vector2i(0, -1))
	if tents[tid].dir == StealthTent.Direction.West:
		wc.global_position = tilemap.map_to_local(wc_pos + Vector2i(1, 0))
	if tents[tid].dir == StealthTent.Direction.East:
		wc.global_position = tilemap.map_to_local(wc_pos + Vector2i(-1 , 0))
	
	# for enemies
	var gi1: StealthEnemy = EnemyRes.instantiate()
	var gi2: StealthEnemy = EnemyRes.instantiate()
	add_child(gi1)
	add_child(gi2)
	pawns.append(gi1)
	pawns.append(gi2)
	if tents[tid].dir == StealthTent.Direction.North:
		gi1.place(wc_pos + Vector2i(1, -1), gi1.Direction.North)
		gi2.place(wc_pos + Vector2i(-1, -1), gi1.Direction.North)
		pass
	if tents[tid].dir == StealthTent.Direction.South:
		gi1.place(wc_pos + Vector2i(1, 1), gi1.Direction.South)
		gi2.place(wc_pos + Vector2i(-1, 1), gi1.Direction.South)
	if tents[tid].dir == StealthTent.Direction.East:
		gi1.place(wc_pos + Vector2i(1 , -1), gi1.Direction.East)
		gi2.place(wc_pos + Vector2i(1 , 1), gi1.Direction.East)
	if tents[tid].dir == StealthTent.Direction.West:
		gi1.place(wc_pos + Vector2i(-1 , -1), gi1.Direction.West)
		gi2.place(wc_pos + Vector2i(-1 , 1), gi1.Direction.West)
	
	for i in range(10):
		var tree = TreeRes.instantiate() 
		var pos = Vector2i(randi_range(2, 18), randi_range(2, 13))
		var ok = true 
		
		if dist(pos, campfire.pos)< 4:
			ok = false
		for tent in tents:
			if dist(pos, tent.pos)< 5:
				ok = false
		for other in trees:
			if dist(pos, other.pos) < 2:
				ok = false
		if not ok:
			continue
		tilemap.add_child(tree)
		tree.place(pos)
		trees.append(tree)

func set_enemies(enemies_: Array[PackedScene], level_: int):
	enemies = enemies_
	level = level_

func on_finish_tactical_map(alive: Array[PackedScene], dead: Array[PackedScene]):
	inventory.characters = alive
	solved.emit(rewards)
	for char_p in dead:
		var char = char_p.instantiate()
		if char.name == game.strat_map.player.mc_name:
			game.strat_map.show_game_over()

func _ready():
	player.pos = Vector2i(1, 1)
	player.sprite.texture = game.strat_map.player.sprite.texture
	gen_field()
	for pawn in pawns:
		pawn.stealth_suicide.connect(kill)
		pawn.setup_nav()
	wc.WCReached.connect(on_wc_activated)

func kill(pawn: StealthEnemy):
	pawns.pop_at(pawns.find(pawn))
	enemies.pop_back()
	remove_child(pawn)

func on_wc_activated():
	wc_reached = true

func get_random_tree():
	return trees[randi_range(0, trees.size() - 1)]

func start_fight():
	var characters = inventory.characters
	game.tactical_map.reinit(characters, enemies, enemy_level)
	game.to_tact_mode()
	game.tactical_map.finish.connect(on_finish_tactical_map)