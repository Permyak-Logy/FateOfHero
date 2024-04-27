class_name SmolIttoUnit extends Unit

var heal_one_ability = IttoA1.new()
var heal_team_ability = IttoA2.new()

func get_abilities():
	return [attack_ability, heal_one_ability, heal_team_ability] + inventory.get_abilities()

func _ready():
	super()
	print(IttoP1)

func apply_passives():
	for p in [IttoP1.new(self)]:
		add_effect(p)
