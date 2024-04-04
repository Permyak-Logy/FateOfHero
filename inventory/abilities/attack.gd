class_name AttackAbility extends Ability
var distance: int

func _init(_distance=1):
	distance = _distance

	acts = 1
	final_act = true
	targets = 1

func apply():
	if owner.damage:
		await owner.play("preattack")
		print("Damaged", (selected[0] as Unit).apply_damage(owner.damage.cur()), "for", selected[0])
		await owner.play("postattack")
		return true
	return false

func auto_select():
	clear()
	var map = owner.get_parent() as TacticalMap
	var units: Array[Unit]
	if owner.controlled_player:
		units = map.get_enemy_units()
	else:
		units = map.get_player_units()
	for unit in units:
		if can_select(unit):
			select(unit)
			return true
	return false

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	var cur_dist = get_map().distance_between_cells(owner.get_cell(), unit.get_cell())
	return cur_dist <= distance
