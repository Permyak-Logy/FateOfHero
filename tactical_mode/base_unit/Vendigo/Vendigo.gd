extends "res://tactical_mode/base_unit/unit.gd"

class_name Vendigo

@onready var tile_map = $"../TileMap"

var current_id_path: Array = []

func walk_along(way: Array):
	current_id_path = way

func _physics_process(_delta):
	if current_id_path.is_empty():
		return
		
	var target_position = tile_map.map_to_local(current_id_path.front())

	global_position = global_position.move_toward(target_position, 3)
	if global_position == target_position:    
		current_id_path.pop_front()
		if not current_id_path:
			walk_finished.emit()

func ai(map: TacticalMap):
	map.acts = 0
	var rng = RandomNumberGenerator.new()
	var path = []
	while len(path) == 0:
		path = map.get_path_to_cell(
			map.to_map(global_position) + Vector2i(
				rng.randi_range(-3, 3), rng.randi_range(-3, 3)))
	walk_along(path)
	await walk_finished
	ai_act_finished.emit()
