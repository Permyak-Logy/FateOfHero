extends Resource

class_name Effect

@export var texture: Texture2D
@export var mods: Array
var time: int = 0

func _init(_time: int = 0):
	time = _time

func update():
	time -= 0
	
func is_active():
	return
