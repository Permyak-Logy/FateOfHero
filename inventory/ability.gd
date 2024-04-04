extends Gear

class_name Ability

@export var acts: int = 0
@export var final_act: bool = false
@export var cooldown: int = 0
@export var limit: int = 0
@export var count: int = -1

@export var targets: int = 0

var description: String = ""

var owner: Unit

signal ready

var cooldown_time = 0
var has_uses = 0

var selected: Array[Node] = []

func _init(_count: int = count):
	count = _count

func set_owner(_owner: Unit = null):
	owner = _owner

func select(node):
	selected.append(node)

func unselect(node):
	selected.erase(node)

func clear():
	selected.clear()

func reset():
	cooldown_time = 0
	if count < 0:
		has_uses = limit
	else:
		has_uses = min(limit, count)

func update():
	cooldown_time = max(cooldown_time - 1, 0)
	if can_use():
		ready.emit()

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
	return false

func can_select(_node: Node) -> bool:
	return false

func can_apply() -> bool:
	return len(selected) == targets

func apply() -> bool:
	return can_apply()

func get_map() -> TacticalMap:
	return owner.get_parent() as TacticalMap

func after_apply():
	cooldown_time = cooldown
	has_uses -= 1
	if count >= 0:
		count -= 1
	var map = get_map()
	if final_act:
		map.acts = 0
	else:
		map.acts -= acts
		
