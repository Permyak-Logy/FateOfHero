class_name TMUnitQueuePanel extends Panel

var unit_cards: Array[TMQueueUnitCard] = []

var card_cls = preload("res://GUI/tactical_mode/unit_queue/unit_card.tscn")
func set_queue(units: Array):
	print("updating_queue")
	while unit_cards:
		(unit_cards.pop_front() as TMQueueUnitCard).free()
	for unit_data in units:
		var act = unit_data[1]
		var unit = unit_data[0]
		var card = card_cls.instantiate()
		unit_cards.append(card)
		card.set_unit(act, unit)
	for card in unit_cards:
		$HBoxContainer.add_child(card)
	
	unit_cards[0].set_big(true)
