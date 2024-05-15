class_name LugozavrA1 extends DirectedAbility

@export var block_moving_effect: BlockStepmoveEffect
@export var power: ModValue = ModValue.new()
var applied: Unit

func apply():
	var unit = selected[0] as Unit
	await owner.play("ability", unit)
	var te = block_moving_effect.duplicate(true)
	te.instigator = owner
	unit.add_effect(te)
	applied = unit
	await owner.play("postability")
	owner.play("idle")

func subapply():
	if not applied:
		return
	await applied.apply_damage(scale * power.mul + power.add, owner)
	get_map().write_info("=> " + applied.unit_name + " варится в желудке (Хп:" +
		str(int(applied.health.cur())) + " / " + str(int(applied.health.get_max())) + ")"
	)

func can_select(node):
	if not super(node):
		return false
	var unit = node as Unit
	var cur_dist = float("inf")
	for cell in unit.get_occupied_cells():
		cur_dist = min(cur_dist, get_map().distance_between_cells(owner.get_cell(), cell))
	return cur_dist <= 1
