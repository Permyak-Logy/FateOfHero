class_name DirectedAbility extends Ability

@export var targets: int = 1
@export var max_targets: int = 0
@export var apply_on: Array[TacticalMap.relation]
@export var can_use_if_only_has_any_selectable_target: bool = true

var selected: Array[Actor] = []
var selectable_tab: Array[Actor] = []


func select(node: Actor):
	selected.append(node)
	if len(selected) > targets and targets > 0:
		unselect(selected[0])
	if is_instance_of(node, Unit):
		get_map().reset_outline_color(node)

func unselect(node: Actor):
	selected.erase(node)
	if is_instance_of(node, Unit):
		get_map().reset_outline_color(node)

func clear():
	while selected:
		var node = selected.pop_front()
		if is_instance_of(node, Unit):
			get_map().reset_outline_color(node)
	selectable_tab.clear()

func fill_overlay() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for actor in selectable_tab:
		cells.append(actor.get_cell())
	return cells


func auto_select() -> bool:
	if len(selectable_tab) > 0:
		var to_select: int
		if max_targets == 0:
			if targets == 0 or targets == -1:
				to_select = len(selectable_tab)
			else:
				to_select = min(len(selectable_tab), targets)
		else:
			to_select = min(len(selectable_tab), max_targets)
		for i in range(to_select):
			select(selectable_tab[i])
		return true
	return false

func tab_next():
	if not selectable_tab:
		return
	for i in range(selectable_tab.find(selected[0]) + 1, len(selectable_tab)):
		if not selectable_tab[i] in selected:
			select(selectable_tab[i])
			return
	for i in range(selectable_tab.find(selected[0])):
		if not selectable_tab[i] in selected:
			select(selectable_tab[i])
			return

func tab_prev():
	if not selectable_tab:
		return
	for i in range(selectable_tab.find(selected[0]) - 1, -1, -1):
		if not selectable_tab[i] in selected:
			select(selectable_tab[i])
			return
	for i in range(len(selectable_tab) - 1, selectable_tab.find(selected[0]), -1):
		if not selectable_tab[i] in selected:
			select(selectable_tab[i])
			return

func find_all_selectable_tab_targets():
	selectable_tab.clear()
	var map = get_map()
	for actor in map.actors:
		if can_select(actor):
			selectable_tab.append(actor)

func can_select(_node: Actor) -> bool:
	var unit = _node as Unit
	if not unit:
		return false
	if not unit.visible:
		return false
	if unit.is_death():
		return false
	return get_map().get_relation(owner, unit) in apply_on

func can_use():
	if not super():
		return false
	if can_use_if_only_has_any_selectable_target:
		find_all_selectable_tab_targets()
		return len(selectable_tab) > 0
	return true

func can_apply() -> bool:
	var up_bound: int
	if max_targets == 0:
		up_bound = targets if targets > 0 else len(selected)
	else:
		up_bound = max_targets
	return targets <= len(selected) and len(selected) <= up_bound and selected
	
