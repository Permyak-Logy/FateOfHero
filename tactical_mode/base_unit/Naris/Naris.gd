extends Unit

class_name NarisUnit

@onready var tile_map = $"../TileMap"
@onready var animation = $AnimationPlayer

var current_id_path: Array = []

func _ready():
	pass

func walk_along(way: Array):
	current_id_path = way

func _physics_process(delta):
	if current_id_path.is_empty():
		animation.play("idle")
		return
		
	var target_position = tile_map.map_to_local(current_id_path.front())
	animation.play("run")
	global_position = global_position.move_toward(target_position, 3)
	if global_position == target_position:    
		current_id_path.pop_front()
		if not current_id_path:
			print("go!")
			walk_finished.emit()
