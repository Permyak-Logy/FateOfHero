class_name EvilPlantA0 extends AoEAbility

@export var root_effect: TempSlowdownEffect
@export var power_attack: float = 1
@export var range_apply: int = 1

func apply():
	await owner.play("attack")
	super()
	await owner.play("postattack")

func apply_on_unit(unit: Unit):
	if get_map().get_relation(owner, unit) == TacticalMap.relation.Enemy:
		unit.apply_damage(owner.damage.cur() * power_attack, owner)
		var e = root_effect.duplicate(true)
		e.instigator = owner
		unit.add_effect(e)

func find_about_cells():
	var map = get_map()
	
	about_cells.clear()
	for _cell in map._astar_board._cells:
		if map.distance_between_cells(_cell, cell) <= range_apply:
			about_cells.append(_cell)

func can_select_cell(_cell: Vector2i):
	return owner.get_cell() == _cell

