class_name W_AbilitySlot extends Button

var ability: Ability

func _init(_ability: Ability):
	ability = _ability


func _ready():
	var t = (load("res://inventory/items/apple.tres") as Item).texture
	# print(t, ability.texture.load_path, load("res://inventory/abilities/melee_attack/texture.png"))
	
	# $Sprite2D.texture = t
