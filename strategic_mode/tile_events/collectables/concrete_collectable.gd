class_name ConcreteCollectable extends Collectable

func _ready():
	init()
	assert(item != null, "collectables need their values refefined in seperate script")
	assert(count != null, "collectables need their values refefined in seperate script")
	sprite.texture = sprite.texture
