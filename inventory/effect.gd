extends Resource

class_name Effect

@export var texture: Texture2D
@export var mods: Array

signal finished
signal updated_mods

var owner: Unit = null

func _init():
	pass

func set_owner(_owner: Unit):
	owner = _owner

func update_on_move():
	pass

func update_on_damage(damage: float, instigator: Node = null) -> float:
	return damage

func update_on_attack(damage: float, recipient: Node = null) -> float:
	return damage
	
func is_active():
	return

func get_mods() -> Array:
	return mods
