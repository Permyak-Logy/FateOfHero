class_name W_BtnAbility extends Button

var ability: Ability


func _ready():
	update()
	
func set_ability(_ability: Ability):
	ability = _ability
	if is_node_ready():
		update()

func update():
	text = ""
	if not ability:
		return
	if ability.can_use():
		if ability.count >= 0 or ability.limit > 0:
			text = "x" + str(ability.has_uses)
	elif ability.cooldown_time > 0:
		text = "Х." + str(ability.cooldown_time)
	else:
		text = "x0"
	if ability.texture:
		icon = ability.texture
	
	disabled = not ability.can_use()
