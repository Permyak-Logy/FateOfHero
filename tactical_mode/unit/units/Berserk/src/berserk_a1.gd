class_name BerserkA1 extends AoEAbility

@export var effect: Effect
@export var power: ModValue = ModValue.new()
@export var range_apply: int = 2

func apply():
	await owner.play("aoe_ability")
	await super()
	await owner.play("idle")

func find_about_cells():
	var map = get_map()
	
	about_cells.clear()
	for _cell in map._astar_board._cells:
		if map.distance_between_cells(_cell, cell) <= range_apply:
			about_cells.append(_cell)

func apply_on_unit(unit: Unit):
	if unit == owner:
		return
		
	get_map().write_info("=> В ярости атакует " + unit.unit_name)
	await unit.apply_damage(scale * power.mul + power.add, owner)
	var e = effect.duplicate(true)
	e.instigator = owner
	unit.add_effect(e)

func can_select(_cell: Vector2i) -> bool:
	return _cell == (owner as Unit).get_cell()
