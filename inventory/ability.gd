class_name Ability extends Gear

@export var acts: int = 0
@export var final_act: bool = false
@export var cooldown: int = 0
@export var limit: int = 0
@export var count: int = -1

@export var scaling_type: Mod.Type = Mod.Type.None

var owner: Node

signal ready

var cooldown_time = 0
var has_uses = 0

@export var only_unit_owner = true

func _init(_count: int = count):
	count = _count

func set_owner(_owner: Node = null):
	if not is_instance_of(_owner, Unit) and only_unit_owner:
		print("Warning! Owner ", _owner, " is not unit for ability ", self)
	owner = _owner

func clear():
	pass

func reset():
	clear()
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


func get_map() -> TacticalMap:
	if is_instance_of(owner, Unit):
		return owner.get_parent() as TacticalMap
	if is_instance_of(owner, TacticalMap):
		return owner as TacticalMap
	return null


func can_apply() -> bool:
	return true

func apply() -> bool:
	return false

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
	clear()
