extends "res://stategic_mode/tile_events/TileEvent.gd"

@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $EventCollider

func open():
	collider.disabled = true
	sprite.frame = 1

func close():
	collider.disabled = false	
	sprite.frame = 0

func activate():
	pass
