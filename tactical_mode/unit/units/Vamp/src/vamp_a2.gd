class_name VampA2 extends AoEAbility

@export var power: ModValue = ModValue.new()
@export var range_apply: int = 1

func apply():
	await owner.play("ability")
	super()
	owner.play("idle")

func find_about_cells():
	var map = get_map()
	
	about_cells.clear()
	for _cell in map._astar_board._cells:
		if map.distance_between_cells(_cell, cell) <= range_apply:
			about_cells.append(_cell)

func apply_on_unit(unit: Unit):
	var d = unit.health.cur() * power.mul + power.add
	get_map().write_info(
		"=> Жрёт хп у " + unit.unit_name + "отнято " + str(int(d))
	)
	unit.health.sub(d)

func can_select(_cell: Vector2i) -> bool:
	return get_map()._astar_board.has_cell(_cell)
