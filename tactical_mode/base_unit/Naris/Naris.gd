extends Unit

class_name NarisUnit

@onready var tile_map = $"../TileMap"
@onready var animation = $AnimationPlayer
@onready var luck_coin_cls = preload("res://inventory/gears/luck_coin.tres")

var current_id_path: Array = []

func _ready():
	if !inventory:
		return
	if inventory.use(luck_coin_cls):
		print("ok")
		reload_all_mods()

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
			walk_finished.emit()
