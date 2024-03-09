extends Node

class_name StatComponent

@export var default_base: float = 0
@export var default_cur: float = 0
@export var default_max: float = 0
@export var reset_on_ready: bool = true
@export var mod_type: Mod.Type

@onready var mod = Mod.new(mod_type)
@onready var characteristic = Characteristic.new(
	default_base, default_cur, default_max)
