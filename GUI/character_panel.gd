extends NinePatchRect

class_name CharacterPanel

@onready var name_label: Label = $HBoxContainer/Character/Name
@onready var sprite: Sprite2D = $HBoxContainer/Character/PictureBack/Holder/CharacterSprite
@onready var sprite_holder = $HBoxContainer/Character/PictureBack/Holder
@onready var gear_slots: Array = $HBoxContainer/Gear.get_children()
@onready var skill_slots: Array = $HBoxContainer/Skills.get_children()
@onready var exp_bar: TextureProgressBar = $HBoxContainer/Character/CenterContainer/ExpProgressBar
@onready var hp_bar: TextureProgressBar = $HBoxContainer/Character/CenterContainer2/HealthBar
@onready var exp_label = $HBoxContainer/Character/CenterContainer/ExpProgressBar/Label
@onready var hp_label = $HBoxContainer/Character/CenterContainer2/HealthBar/Label
var current_character: Unit = null

func update_gear(gear: Array[Item]):
	pass 

func update_skills():
	pass 


func update_bars():
	hp_bar.max_value = current_character.health.get_max()
	hp_bar.value = current_character.health.cur()
	hp_label.text = str(current_character.health.cur()) + "/" + str(current_character.health.get_max())
	#exp_bar.max_value = current_character.tpr.get_max()
	#exp_bar.value = current_character.tpr.cur()
	#exp_label.text = str(current_character.tpr.cur()) + "/" + str(current_character.health.get_max())
	pass 

func update_repr():
	name_label.text = current_character.name
	if sprite_holder.get_child_count():
		sprite_holder.remove_child(sprite)
		
	
	sprite = current_character.sprite_for_outline.duplicate()
	sprite.centered = false
	sprite.offset = Vector2i(0, 24)
	sprite_holder.add_child(sprite)
	pass 
	

func update():
	update_repr()
	update_bars()
	#update_gear()
	#update_skills()
	pass



func change_character(character: PackedScene) -> PackedScene:
	var old_char = null
	if current_character:
		old_char = PackedScene.new()
		current_character.visible = true
		sprite_holder.remove_child(current_character)
		old_char.pack(current_character)
		  
	current_character = character.instantiate()
	current_character.visible = false
	sprite_holder.add_child(current_character)
	print("changed displayed character to <",current_character.name ,">" )
	update()
	return old_char
