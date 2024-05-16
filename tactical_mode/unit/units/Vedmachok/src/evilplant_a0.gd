class_name EvilPlantA0 extends AoEAbility

@export var root_effect: TempSlowdownEffect
@export var power: ModValue = ModValue.new()
@export var range_apply: int = 2
@export var range_root: int = 1

func apply():
	await owner.play("preattack")
	super()
	await owner.play("postattack")

func apply_on_unit(unit: Unit):
	if get_map().get_relation(owner, unit) == TacticalMap.relation.Enemy:
		unit.apply_damage(scale * power.mul + power.add, owner)
		if get_map().distance_between_cells(owner.get_cell(), unit.get_cell()) <= range_root:
			var e = root_effect.duplicate(true)
			e.instigator = owner
			unit.add_effect(e)

func find_about_cells():
	var map = get_map()
	
	about_cells.clear()
	for _cell in map._astar_board._cells:
		if map.distance_between_cells(_cell, cell) <= range_apply:
			about_cells.append(_cell)

func can_select(_cell: Vector2i):
	return owner.get_cell() == _cell

