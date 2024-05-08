class_name DangerIce extends Actor

func _ready():
	$Sprite2D.scale = Vector2(0, 0)

func _process(delta):
	if $Sprite2D.scale != Vector2(1, 1):
		$Sprite2D.scale = $Sprite2D.scale.move_toward(Vector2(1, 1), 0.01)

func get_occupied_cells() -> Array[Vector2i]:
	return []
