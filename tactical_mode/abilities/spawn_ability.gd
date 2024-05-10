class_name SpawnAbility extends AoEAbility

@export var mob: PackedScene
@export var range_apply: int = 1
@export var kill_all_mobs_on_death_owner: bool = true

var plants: Array[EvilPlantUnit] = []

func apply():
	var map = get_map()
	var unit = map.spawn(mob, cell, owner)
	map.add_to_unit_queue(unit, true)
	if kill_all_mobs_on_death_owner:
		(owner as Unit).death.connect(unit.kill)

func can_select_cell(_cell: Vector2i) -> bool:
	if get_map().distance_between_cells(owner.get_cell(), _cell) > range_apply:
		return false
	if not get_map()._astar_board.has_cell(_cell):
		return false
	return not get_map().is_occupied(_cell)
