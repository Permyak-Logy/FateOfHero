extends "res://external_puzzles/puzzles/base_puzzle.gd"

class_name SafePath
@onready var inventory: Inventory = preload("res://inventory/global_inventory.tres")
@onready var tilemap: TileMap = $TileMap
@onready var player: WASDPlayer = $player
@onready var game: Game = get_tree().root.get_child(0)
@onready var wc: EPWinCondition = load("res://external_puzzles/puzzles/safe_path/win_condition_point.tscn").instantiate()

var enemies: Array[PackedScene]

var field_size: Vector2i = Vector2i(11, 14)
var end_pos: Vector2i = Vector2i(5, 0)
var curve_count: int = 3
var curve_prescision: int = 100_000

var danger_tile_atlas_coords = Vector2i(0, 0)

func flip(v: Vector2i) -> Vector2i:
	return Vector2i(v.y, v.x)

func p_less(p1:Vector2i, p2:Vector2i) -> bool:
	if (p1[1] < p2[1]):
		return true 
	elif (p1[1] > p2[1]):
		return false
	else:
		return p1[0] < p2[0]

func p_greater(p1:Vector2i, p2:Vector2i):
	return not p_less(p1, p2)

func bezier_point(p1: Vector2, p2: Vector2, p3: Vector2, pos: float) -> Vector2:
	# pos E [0, 1]
	# p1, p3 on oncurve, p2 off curve 
	var m1: Vector2 = (p1 * (1 - pos)) + (p2 * pos)
	var m2: Vector2 = (p2 * (1 - pos)) + (p3 * pos)
	var m3: Vector2 = (m1 * (1 - pos)) + (m2 * pos)
	return m3

func bezier_curve(p1: Vector2, p2: Vector2, p3: Vector2, points_count: int) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for i in range(points_count):
		var pos: float = float(i) / float(points_count - 1)
		points.append(bezier_point(p1, p2, p3, pos))
	return points

func gen_field():
	print("starting generation")
	var start = tilemap.map_to_local(player.pos)
	var end = tilemap.map_to_local(end_pos)
	var on_curve_point_count = curve_count - 1
	var off_curve_point_count = curve_count
	
	var max_x = tilemap.map_to_local(field_size - Vector2i(1, 1)).x
	var max_y = tilemap.map_to_local(field_size - Vector2i(1, 1)).y
	print(max_x, " ",max_y)
	var on_curve_points = []
	var rng = RandomNumberGenerator.new()
	for i in range(on_curve_point_count):
		var point = Vector2(rng.randf_range(1, max_x - 1), rng.randf_range(1, max_y - 1))
		on_curve_points.append(point)
	on_curve_points.sort_custom(p_greater)
	
	var off_curve_points = []
	for i in range(off_curve_point_count):
		var point = Vector2(rng.randf_range(1, max_x - 1), rng.randf_range(1, max_y - 1))
		off_curve_points.append(point)
	
	# array[array[bool]]
	# field is indexed [y][x] as quirk of the tilema[ 
	var field: Array[Array] = []
	for y in range(field_size.y):
		var column: Array[bool] = []
		for x in range(field_size.x):
			column.append(true)
		field.append(column)
	print("_______________________________________________________")
	print("curve 0: p1:", start, ", p2: ", off_curve_points[0], ", p3: ", on_curve_points[0])
	print("tilevise curve 0: p1:", tilemap.local_to_map(start), 
	", p2: ", tilemap.local_to_map(off_curve_points[0]), 
	", p3: ", tilemap.local_to_map(on_curve_points[0]))
	for point in bezier_curve(start, off_curve_points[0], on_curve_points[0], curve_prescision):
		var pos = tilemap.local_to_map(point)
		if field[pos.y][pos.x]:
			field[pos.y][pos.x] = false
	
	for cid in range(1, on_curve_point_count):
		print("_______________________________________________________")
		print("curve ", cid, ": p1:", on_curve_points[cid - 1], ", p2: ", off_curve_points[cid], ", p3: ", on_curve_points[cid])
		
		print("tilevise curve ", cid, ": p1:", tilemap.local_to_map(on_curve_points[cid-1]), 
		", p2: ", tilemap.local_to_map(off_curve_points[cid]), 
		", p3: ", tilemap.local_to_map(on_curve_points[cid]))
		var curve: Array[Vector2] = bezier_curve(on_curve_points[cid - 1], 
		off_curve_points[cid], on_curve_points[cid], curve_prescision)
		for point in curve:
			var pos = tilemap.local_to_map(point)
			if field[pos.y][pos.x]:
				field[pos.y][pos.x] = false
	
	
	print("_______________________________________________________")
	print("curve ", curve_count - 1, ": p1:", on_curve_points[-1], ", p2: ", off_curve_points[-1], ", p3: ", end)
	print("tilevise curve ", curve_count - 1, ": p1:", tilemap.local_to_map(on_curve_points[-1]), 
	", p2: ", tilemap.local_to_map(off_curve_points[-1]), 
	", p3: ", tilemap.local_to_map(end))
	
	for point in bezier_curve(on_curve_points[-1], off_curve_points[-1], end, curve_prescision):
		var pos = tilemap.local_to_map(point)
		if field[pos.y][pos.x]: 
			field[pos.y][pos.x] = false
	
	for y in range(field_size.y):
		print(y, ": ", field[y])
		for x in range(field_size.x):
			var pos = Vector2i(x, y)
			if field[y][x]:
				tilemap.set_cell(0, pos, 0, danger_tile_atlas_coords)

func _ready():
	gen_field()
	wc.WCReached.connect(end_successfully)
	add_child(wc)
	wc.global_position = tilemap.map_to_local(end_pos)
	player.global_position = tilemap.map_to_local(player.pos)
	player.speed = 8 * tilemap.tile_set.tile_size.length()

func set_enemies(enemies_: Array[PackedScene]):
	enemies = enemies_

func end_successfully():
	solved.emit(rewards)

func start_fight():
	var characters = inventory.characters
	game.tactical_map.reinit(characters, enemies)
	game.to_tact_mode()
	game.tactical_map.finish.connect(on_finish_tactical_map)

func on_finish_tactical_map(alive: Array[PackedScene], dead: Array[PackedScene]):
	inventory.characters = alive
	solved.emit(rewards)
	game.to_strat_mode()
