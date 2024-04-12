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
		print("Damaged", (selected[0] as Unit).apply_damage(owner.damage.cur(), owner), "for", selected[0])
		await owner.play("postattack")
		return true
	return false

func tab_next(prev=false):
	if not selectable_tab:
		return
	
	if not prev:
		for i in range(selectable_tab.find(selected[0]) + 1, len(selectable_tab)):
			if not selectable_tab[i] in selected:
				select(selectable_tab[i])
				return
		for i in range(selectable_tab.find(selected[0])):
			if not selectable_tab[i] in selected:
				select(selectable_tab[i])
				return
	else:
		for i in range(selectable_tab.find(selected[0]) - 1, -1, -1):
			if not selectable_tab[i] in selected:
				select(selectable_tab[i])
				return
		for i in range(len(selectable_tab) - 1, selectable_tab.find(selected[0]), -1):
			if not selectable_tab[i] in selected:
				select(selectable_tab[i])
				return

func find_all_selectable_tab_targets():
	var map = owner.get_parent() as TacticalMap
	var units: Array[Unit]
	if owner.controlled_player:
		units = map.get_enemy_units()
	else:
		units = map.get_player_units()
	for unit in units:
		if can_select(unit):
			selectable_tab.append(unit)

func can_select(node):
	var unit = node as Unit
	if not unit:
		return false
	if unit.is_death():
		return false
	if get_map().is_player(owner) != get_map().is_enemy(node):
		return false
	var cur_dist = get_map().distance_between_cells(owner.get_cell(), unit.get_cell())
	return cur_dist <= distance
