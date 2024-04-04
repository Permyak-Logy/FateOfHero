extends Node

class_name StatComponent

@export var default_base: float = 0
@export var default_cur: float = 0
@export var default_max: float = 0
@export var reset_on_ready: bool = true
@export var mod_type: Mod.Type = Mod.Type.None

@onready var mod = Mod.new(mod_type)
@onready var unit: Unit
@onready var _characteristic = Characteristic.new(default_base, default_cur, default_max)

signal empty
signal full


func _ready():
	if is_instance_of($"..", Unit):
		unit = $".."
	
	if reset_on_ready:
		_characteristic.cur = _characteristic.base
		_characteristic.max_ = max(_characteristic.base, _characteristic.max_)
		reload_mods()

func percent():
	return _characteristic.percent()

func cur():
	return _characteristic.cur

func get_max() -> float:
	return _characteristic.max_

func get_base():
	return _characteristic.base

func set_cur(value):
	_characteristic.set_cur(value)
	if value == 0:
		empty.emit()
	if value == _characteristic.max_:
		full.emit()

func add(value: float):
	set_cur(_characteristic.cur + value)

func sub(value: float):
	set_cur(_characteristic.cur - value)

func rebase(value: float, save_percent: bool = true):
	var p = percent()
	_characteristic.base = value
	_characteristic.max_ = _characteristic.base * mod.value.mul + mod.value.add
	if save_percent:
		_characteristic.cur = _characteristic.max_ * p

func reload_mods(save_percent: bool = true):
	var p = percent()
	mod.value.clear()
	if unit and unit.inventory:
		var _mods = unit.inventory.get_mods()
		var _mod = _mods.get(mod_type, ModValue.new())
		mod.value.iadd(_mod)
	_characteristic.max_ = _characteristic.base * (mod.value.mul / 100 + 1) + mod.value.add
	if save_percent:
		_characteristic.set_cur(_characteristic.max_ * p)
	else:
		_characteristic.set_cur(_characteristic.cur)



