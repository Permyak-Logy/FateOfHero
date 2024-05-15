class_name ConcreteCollectable extends Collectable

func _ready():
	init()
	assert(item != null, "Ты забыл добавить предмет")
	assert(count != null, "Ты забыл добавить предмет")
	sprite.texture = item.texture
