class_name VendigoP1 extends Effect

@export var power_damage: float = 0.2

var danger_ice = preload("res://tactical_mode/unit/units/Vendigo/DangerIce.tscn")
var freezing = preload("res://tactical_mode/unit/units/Vendigo/res/Freezing.tres")
var ices = {} # Dict[Vector2i: DangerIce]

func update_on_move():
	var map: TacticalMap = owner.get_map()
	
	var to_spawn = []
	for cell in owner.get_occupied_cells():
		if not ices.has(cell):
			to_spawn.append(cell)
	
	for cell in ices.keys():
		for cell_about in map._astar_board.get_about_cells(cell):
			if cell_about in ices.keys() or cell_about in to_spawn:
				continue
			to_spawn.append(cell_about)
	
	for cell in to_spawn:
		ices[cell] = map.spawn(danger_ice, cell)
	get_map().write_info("=> Лёд разрастается... (" + owner.unit_name + ")")
	for unit in map.get_units_with_relation(owner, TacticalMap.relation.Enemy):
		if ices.has(unit.get_cell()) and not unit.is_death():
			unit.apply_damage(owner.damage.cur() * power_damage, owner)
			var e = freezing.duplicate(true)
			e.instigator = owner
			unit.add_effect(e)
			get_map().write_info(
				"-> Ух... Холодно... " + unit.unit_name + " скорость: " + str(int(unit.speed.cur()))
			)
