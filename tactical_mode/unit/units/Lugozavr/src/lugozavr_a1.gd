class_name LugozavrA1 extends DirectedAbility

@export var block_moving_effect: BlockMovingEffect
@export var power_p: float = 1
var applied: Unit

func apply():
	var unit = selected[0] as Unit
	var te = block_moving_effect.duplicate(true)
	te.instigator = owner
	unit.add_effect(te)
	applied = unit

func subapply():
	if not applied:
		return
	
	get_map().write_info("=> " + applied.unit_name + " варится в желудке получая (Хп:" +
		str(applied.health.cur()) + " / " + str(applied.health.get_max()) + ")"
	)

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	if not unit.visible:
		return false
	if get_map().is_player(owner) == get_map().is_player(node):
		return false
	var cur_dist = float("inf")
	for cell in unit.get_occupied_cells():
		cur_dist = min(cur_dist, get_map().distance_between_cells(owner.get_cell(), cell))
	return cur_dist <= 1
