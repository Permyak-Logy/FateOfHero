extends "res://strategic_mode/tile_events/TileEvent.gd"

@onready var collider: CollisionShape2D = $EventCollider

func _ready():
	pass

func open():
	collider.disabled = true
	sprite.frame = 1

func close():
	collider.disabled = false	
	sprite.frame = 0

func activate():
	pass
