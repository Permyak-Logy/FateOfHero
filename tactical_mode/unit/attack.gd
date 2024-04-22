class_name AttackAbility extends Ability
@export var distance: int = 1

func _init(_distance=distance):
	distance = _distance

	acts = 1
	final_act = true
	targets = 1
	name = "Атака"

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
	var cur_dist = get_map().distance_between_cells(owner.get_cell(), unit.get_cell())
	if unit.cells_occupied == 2:
		cur_dist = min(cur_dist, get_map().distance_between_cells(
			owner.get_cell(), unit.get_cell() + Vector2i(1, 0)))
	return cur_dist <= distance
