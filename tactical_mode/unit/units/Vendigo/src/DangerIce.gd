class_name DangerIce extends Actor

@export var sprite: Sprite2D

var aliave = true

func _ready():
	sprite.scale = Vector2(0, 0)

func _process(delta):
	if aliave:
		if sprite.scale != Vector2(1, 1):
			sprite.scale = sprite.scale.move_toward(Vector2(1, 1), 0.01)
	elif sprite.scale == Vector2(0, 0):
		queue_free()
	else:
		sprite.scale = sprite.scale.move_toward(Vector2(0, 0), 0.005)

func get_occupied_cells() -> Array[Vector2i]:
	return []

func death_owner(owner: Unit):
	aliave = false
