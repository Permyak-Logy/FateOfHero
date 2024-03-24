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
	return false
	
func auto_select() -> bool:
	return false

func can_select(node: Node) -> bool:
	return false

func can_apply() -> bool:
	return len(selected) == targets

func apply() -> bool:
	if not can_apply():
		return false
	return true

func after_apply():
	cooldown_time = cooldown
	has_uses -= 1
	if count >= 0:
		count -= 1
