class_name BerserkA1 extends AoEAbility

@export var power_attack: float = 0.2
@export var range_apply: int = 2

func find_about_cells():
	var map = get_map()
	
	about_cells.clear()
	for _cell in map._astar_board._cells:
		if map.distance_between_cells(_cell, cell) <= range_apply:
			about_cells.append(_cell)

func apply_on_unit(unit: Unit):
	if unit == owner:
		return
	get_map().write_info(
		"=> В ярости атакует " + unit.unit_name + "отнято " + str(int(unit.apply_damage(
			(owner as Unit).damage.cur() * power_attack, owner))))

func can_select_cell(_cell: Vector2i) -> bool:
	return _cell == (owner as Unit).get_cell()
