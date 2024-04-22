extends Resource

class_name Effect

@export var texture: Texture2D
@export var mods: Array[Mod] = []
@export var destroy_on_death_instigator: bool = false

signal finished
signal updated_mods

var owner: Unit = null
var instigator: Node
var is_negative: bool

func _init(_instigator: Node = null, is_negative: bool = false):
	instigator = _instigator

func _ready():
	if destroy_on_death_instigator and is_instance_of(instigator, Unit):
		(instigator as Unit).death.connect(func (_x) : finished.emit(self))

func set_owner(_owner: Unit):
	owner = _owner

func update_on_move():
	pass

func update_on_damage(damage: float, _instigator: Node = null) -> float:
	return damage

func update_on_attack(damage: float, _recipient: Node = null) -> float:
	return damage
	
func is_active():
	return

func get_mods() -> Array[Mod]:
	return mods
