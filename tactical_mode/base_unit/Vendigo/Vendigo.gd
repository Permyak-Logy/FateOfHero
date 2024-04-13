class_name Vendigo extends Unit

@onready var tile_map = $"../TileMap"

var current_id_path: Array = []

signal walk_finished

func play(_name, _args=null):
	if _name == "walk":
		current_id_path = _args
		await walk_finished

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
	await play("walk", path)
