class_name VampA2 extends AoEAbility

@export var power: ModValue = ModValue.new()
@export var range_apply: int = 1

func apply():
	await super()
	owner.play("idle")

func find_about_cells():
	var map = get_map()
	
	about_cells.clear()
	for _cell in map._astar_board._cells:
		if map.distance_between_cells(_cell, cell) <= range_apply:
			about_cells.append(_cell)

func apply_on_unit(unit: Unit):
	if unit.is_death():
		return
	if not unit.visible:
		return
	var d = unit.health.cur() * power.mul + power.add
	
	await owner.play("ability")
	await unit.apply_damage(d, owner)

func can_select(_cell: Vector2i) -> bool:
	return get_map()._astar_board.has_cell(_cell)
