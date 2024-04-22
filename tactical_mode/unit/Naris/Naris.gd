class_name NarisUnit extends Unit

@onready var animation = $AnimationPlayer

var my_defense_ability = NarisA1.new()
var hidden_armor_ability = NarisA2.new()

func get_abilities():
	return [attack_ability, my_defense_ability, hidden_armor_ability] + inventory.get_abilities()

func play(_name, _params=null):
	if _name in ["idle", "run"]:
		animation.play(_name)
	else:
		await super(_name, _params)
