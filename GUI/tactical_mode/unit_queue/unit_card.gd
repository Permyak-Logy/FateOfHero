class_name TMQueueUnitCard extends NinePatchRect
@onready var sprite = $Control/Sprite2D
@onready var inititative_label = $Initiative
	

var unit
var initative

func set_unit(_unit: Unit, _initative: int):
	assert(_unit)
	assert(_unit.icon, "unit " + _unit.unit_name + " has no icon.")
	unit = _unit
	initative = _initative

func set_big(toggle:bool):
	if toggle:
		custom_minimum_size *= 1.5
		sprite.scale *= 1.5
	else:
		custom_minimum_size /= 1.5
		sprite.scale /= 1.5

func _ready():
	sprite.texture = unit.icon
	inititative_label.text = str(initative)
