class_name LugozavrA1 extends DirectedAbility

@export var block_moving_effect: BlockMovingEffect

var applied: Unit

func apply():
	var unit = selected[0] as Unit
	var te = block_moving_effect.duplicate(true)
	te.instigator = owner
	unit.add_effect(te)
	applied = unit

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	if get_map().is_player(owner) == get_map().is_player(node):
		return false
	var cur_dist = float("inf")
	for cell in unit.get_occupied_cells():
		cur_dist = min(cur_dist, get_map().distance_between_cells(owner.get_cell(), cell))
	return cur_dist <= 1
