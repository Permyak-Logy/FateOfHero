class_name GGVamp extends Unit

var a1 = GGVampA1.new()
var a2 = GGVampA2.new()
var a3 = GGVampA3.new()

func get_abilities():
	return [attack_ability, a1, a2, a3] + inventory.get_abilities()

func apply_passives():
	for p in [GGVampP1.new(self), GGVampP2.new(self)]:
		add_effect(p)
