class_name NarisUnit extends Unit

@onready var tile_map = $"../TileMap"
@onready var animation = $AnimationPlayer
@onready var luck_coin_cls = preload("res://inventory/gears/luck_coin.tres")

var current_id_path: Array = []

signal walk_finished

func _ready():
	super._ready()
	if $InventoryComponent.use(luck_coin_cls):
		reload_all_mods()

func play(name, params=null):
	if name == "walk":
		current_id_path = params
		await walk_finished
	else:
		super.play(name)

func _physics_process(_delta):
	if current_id_path.is_empty():
		animation.play("idle")
		return

	var target_position = tile_map.map_to_local(current_id_path.front())
	animation.play("run")
	var old_global_position = global_position
	global_position = global_position.move_toward(target_position, 5)
	if ((global_position - old_global_position)[0] < 0) != ($Sprite2D.scale[0] < 0):
		$Sprite2D.scale[0] = -$Sprite2D.scale[0]
	if global_position == target_position:    
		current_id_path.pop_front()
		if not current_id_path:
			$Sprite2D.scale = Vector2(1, 1)
			walk_finished.emit()
