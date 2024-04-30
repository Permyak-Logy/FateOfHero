class_name AttackAbility extends DirectedAbility
@export var distance: int = 1

func apply():
	if owner.damage:
		await owner.play("preattack")
		var damaged = (selected[0] as Unit).apply_damage(owner.damage.cur(), owner)
		print("=> Attack damage ", damaged, " for ", selected[0].unit_name, " by ", owner.unit_name)
		await owner.play("postattack")
		return true
	return false

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	if get_map().is_player(owner) == get_map().is_player(node):
		return false
	var cur_dist = float("inf")
	for cell in unit.get_occupied_cells():
		cur_dist = min(cur_dist, get_map().distance_between_cells(owner.get_cell(), cell))
	return cur_dist <= distance
