extends Button

class_name W_AbilitySlot


var ability: Ability
func _init(_ability: Ability):
	ability = _ability
	ability.texture
	($Background as Sprite2D).texture = ability.texture
