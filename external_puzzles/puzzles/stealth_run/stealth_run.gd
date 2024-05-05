class_name StealthRun extends BasePuzzle

@onready var tilemap: TileMap = $TileMap
@onready var player: WASDPlayer

var field_size: Vector2i = Vector2i(20, 15)

var CampfireRes: PackedScene = preload("res://external_puzzles/puzzles/stealth_run/obstacles/campfire.tscn")
var TreeRes: PackedScene = preload("res://external_puzzles/puzzles/stealth_run/obstacles/tree.tscn")
var TentRes: PackedScene = preload("res://external_puzzles/puzzles/stealth_run/obstacles/tent.tscn")
var EnemyRes: PackedScene = preload("res://external_puzzles/puzzles/stealth_run/obstacles/stealth_enemy.tscn")

var enemies: Array[PackedScene]
var pawns: Array[StealthEnemy] = []

func dist(a: Vector2i, b: Vector2i) -> int:
	return max(abs(a.x - b.x), abs(a.y - b.y))

func gen_field():
	var rng = RandomNumberGenerator.new()
	var campfire = CampfireRes.instantiate()
	tilemap.add_child(campfire)
	campfire.place(field_size / 2 +\
	 Vector2i(randi_range(-3 , 3), randi_range(-3 , 3)))
	var ci = EnemyRes.instantiate()
	
	
	var tents = []
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
	
	var trees = []
	
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

func set_enemies(enemies_: Array[PackedScene]):
	enemies = enemies_

func _ready():
	gen_field()
