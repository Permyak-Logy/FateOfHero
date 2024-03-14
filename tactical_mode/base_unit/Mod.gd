extends Node

class_name Mod

class Value:
	var add: float
	var mul: float

	func _init(_add = 0., _mul = 0.):
		add = _add
		_mul = _mul
	func clear():
		add = 0
		mul = 0
		
enum Type {Health, Speed, Damage, Defence, None}

var type: Type
var value: Value

func _init(t: Type, v: Value = Value.new()):
	type = t
	value = v
