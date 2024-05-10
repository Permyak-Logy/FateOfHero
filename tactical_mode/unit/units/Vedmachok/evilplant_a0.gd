class_name EvilPlantA0 extends AoEAbility

@export var root_effect: TempSlowdownEffect
@export var power_attack: float = 1
@export var range_apply: int = 1

func apply():
	await owner.play("attack")
	for unit in get_map().units:
		for cell in unit.get_occupied_cells():
			if cell in about_cells:
				print(".0||||", owner, len(owner.death.get_connections()))
				apply_on_unit(unit)
				print("..0||||", owner, len(owner.death.get_connections()))
				break
	print("1||||", owner, len(owner.death.get_connections()))
	await owner.play("postattack")
	print("2||||", owner, len(owner.death.get_connections()))

func apply_on_unit(unit: Unit):
	if get_map().get_relation(owner, unit) == TacticalMap.relation.Enemy:
		unit.apply_damage(owner.damage.cur() * power_attack, owner)
		var e = root_effect.duplicate(true)
		e.instigator = owner
		print(owner, len(owner.death.get_connections()))
		unit.add_effect(root_effect)
		print("-1||||", owner, len(owner.death.get_connections()))

func find_about_cells():
	var map = get_map()
	
	about_cells.clear()
	for _cell in map._astar_board._cells:
		if map.distance_between_cells(_cell, cell) <= range_apply:
			about_cells.append(_cell)

func can_select_cell(_cell: Vector2i):
	return owner.get_cell() == _cell

