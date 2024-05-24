class_name TMUnitQueuePanel extends Panel

# it won't change, hence this system
@onready var unit_cards: Array[TMQueueUnitCard] = [
	$HBoxContainer/UnitCard1,
	$HBoxContainer/UnitCard2,
	$HBoxContainer/UnitCard3,
	$HBoxContainer/UnitCard4,
	$HBoxContainer/UnitCard5,
	$HBoxContainer/UnitCard6,
	$HBoxContainer/UnitCard7
]

func set_queue(units: Array):
	#array[(initiative, unit)]
	print("updating_queue")
	for i in range(7):
		unit_cards[i].set_unit(units[i % len(units)][1], units[i % len(units)][0])
