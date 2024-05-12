class_name StealthPlayer extends WASDPlayer


func wasd_move(event):
	var p: StealthRun = puzzle as StealthRun
	var delta = Vector2i(0, 0)
	if event.is_action_pressed("up"):
		delta[1] -= 1
	if event.is_action_pressed("down"):
		delta[1] += 1
	if event.is_action_pressed("left"):
		delta[0] -= 1
	if event.is_action_pressed("right"):
		delta[0] += 1
	if puzzle.tilemap.get_cell_tile_data(0, pos + delta).get_custom_data("walkable"):
		pos += delta
	if pos.x == 0 or pos.x == 20 or pos.y == 0 or pos.y == 15:
		if p.wc_reached:
			p.solved.emit(p.rewards)
	

