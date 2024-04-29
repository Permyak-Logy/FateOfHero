class_name DirectedAbility extends Ability

@export var targets: int = 1
@export var max_targets: int = 0

var selected: Array[Node] = []
var selectable_tab: Array[Node] = []


func select(node):
	selected.append(node)
	if len(selected) > targets and targets > 0:
		unselect(selected[0])
	if is_instance_of(node, Unit):
		get_map().reset_outline_color(node)

func unselect(node):
	selected.erase(node)
	if is_instance_of(node, Unit):
		get_map().reset_outline_color(node)

func clear():
	while selected:
		var node = selected.pop_front()
		if is_instance_of(node, Unit):
			get_map().reset_outline_color(node)
	selectable_tab.clear()


func can_use() -> bool:
	if not owner:
		return false
	if cooldown_time > 0:
		return false
	if has_uses == 0 and limit > 0:
		return false
	if get_map().acts < acts:
		return false
	return true
	
func auto_select() -> bool:
	if len(selectable_tab) > 0:
		var to_select: int
		if max_targets == 0:
			if targets == 0:
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
	var map = get_map()
	for unit in map.units:
		if can_select(unit):
			selectable_tab.append(unit)

func can_select(_node: Node) -> bool:
	return true

func get_map() -> TacticalMap:
	if is_instance_of(owner, Unit):
		return owner.get_parent() as TacticalMap
	if is_instance_of(owner, TacticalMap):
		return owner as TacticalMap
	return null

func can_apply() -> bool:
	var up_bound: int
	if max_targets == 0:
		up_bound = targets if targets > 0 else len(selected)
	else:
		up_bound = max_targets
	return targets <= len(selected) and len(selected) <= up_bound