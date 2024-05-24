class_name VeryStrongGravityEffect extends Effect

@export var mod_value: ModValue

func update_on_start_stepmove():
	if randf() > dist() - 8 / 5:
		await gravity_apply()
	if randf() > dist() - 4 / 5:
		await gravity_apply()
	await gravity_apply()
	await damage_apply()

func update_on_move(distance: float) -> float:
	if dist() == 0:
		return 0
	return distance

func dist() -> int:
	return get_map().distance_between_cells(owner.get_cell(), instigator.get_cell())

func gravity_apply():
	get_map().write_info("Притягивание чёрной дыры")
	if owner.get_cell() == instigator.get_cell():
		return
	var d = dist()
	var map = get_map()
	var cells = [owner.get_cell(), instigator.get_cell()]
	for cell in map._astar_board._cells:
		var cd = map.distance_between_cells(cell, instigator.get_cell())
		if cd >= d:
			continue
		if map.is_occupied(cell) and cd == d - 1:
			continue
		cells.append(cell)
	var astar = AStarHexagon2D.new(cells)
	var path = astar.get_id_path(
		astar.mti(owner.get_cell()), 
		astar.mti(instigator.get_cell())
	)
	if not path:
		return
	
	await owner.play("preteleport")
	map.move_unit_to(owner, astar.itm(path[1]))
	await owner.play("postteleport")
	map._update_walls()

func damage_apply():
	if not owner.health:
		return
	print("Нанесение урона от чёрной дыры")
	if dist() > 2:
		return
	elif dist() > 1:
		await owner.apply_damage(owner.health.get_max() * 0.01, instigator)
	elif dist() > 0:
		await owner.apply_damage(owner.health.get_max() * 0.15, instigator)
	else:
		await owner.apply_damage(owner.health.get_max() * 0.3, instigator)
