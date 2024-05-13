class_name GateTileEvent extends UnwalkableTileEvent

@onready var collider: CollisionShape2D = $EventCollider
@export var is_open: bool = false

func _ready():
	close()
	if is_open:
		open()
	strat_map.strat_map_loaded.connect(snap_to_grid)

func open(_null=null):
	collider.disabled = true
	strat_map.tilemap.set_walkable(map_pos, true)
	sprite.frame = 1

func close():
	collider.disabled = false
	strat_map.tilemap.set_walkable(map_pos, false)
	sprite.frame = 0

func activate():
	pass
