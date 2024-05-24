class_name TMQueueUnitCard extends NinePatchRect
@onready var sprite = $Control/Sprite2D
@onready var inititative_label = $Initiative
	
func set_unit(unit: Unit, initative: int):
	assert(unit)
	assert(unit.icon, "unit "+unit.unit_name+" has no icon.")
	sprite.texture = unit.icon
	inititative_label.text = str(initative)
