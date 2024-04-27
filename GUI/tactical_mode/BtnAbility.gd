class_name W_BtnAbility extends TextureButton

var ability: Ability

@onready var label: Label = $Label

func _ready():
	label.text = str(ability.cooldown_time)

func set_ability(_ability: Ability):
	ability = _ability
