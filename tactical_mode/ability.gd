class_name Ability extends Gear

@export var acts: int = 0
@export var final_act: bool = false
@export var cooldown: int = 0
@export var limit: int = 0
@export var consumable: bool = false
@export var count: int = 0

enum indicator {Base, Cur, Max}
@export var scaling_type: Mod.Type = Mod.Type.None
@export var scaling_stat: indicator = indicator.Cur
@export var overlay_atlas_coords: Vector2i = Vector2i(1, 0)

var owner: Node

signal ready

var cooldown_time = 0
var has_uses = 0

@export var only_unit_owner = true
var scale: float = 0:
	get:
		var stat = (owner as Unit).stat_from_type(scaling_type)
		if scaling_stat == indicator.Cur:
			return stat.cur()
		if scaling_stat == indicator.Base:
			return stat.get_base()
		if scaling_stat == indicator.Max:
			return stat.get_max()
		return 0

func _init(_count: int = count):
	count = _count

func set_owner(_owner: Node = null):
	if not is_instance_of(_owner, Unit) and only_unit_owner:
		print("Warning! Owner ", _owner, " is not unit for ability ", self)
	owner = _owner

func fill_overlay() -> Array[Vector2i]:
	return []

func clear():
	pass

func reset():
	clear()
	cooldown_time = 0
	has_uses = limit
	if consumable:
		if limit > 0:
			has_uses = min(limit, count)
		else:
			has_uses = count

func update():
	cooldown_time = max(cooldown_time - 1, 0)
	if can_use():
		ready.emit()

func can_use() -> bool:
	if not owner:
		return false
	if has_uses == 0 and (limit > 0 or consumable):
		return false
	if cooldown_time > 0:
		return false
	if get_map().acts < acts:
		return false
	return true

func get_map() -> TacticalMap:
	if is_instance_of(owner, Unit):
		return owner.get_map()
	if is_instance_of(owner, TacticalMap):
		return owner as TacticalMap
	return null

func can_apply() -> bool:
	return true

func apply():
	pass

func after_apply():
	cooldown_time = cooldown + 1
	has_uses -= 1
	if consumable and count >= 0:
		count -= 1
	var map = get_map()
	if final_act:
		map.acts = 0
	else:
		map.acts -= acts
	clear()
