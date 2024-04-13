extends NinePatchRect

class_name CharacterPanel

@onready var name_label: Label = $HBoxContainer/Character/Name
@onready var sprite: Sprite2D = $HBoxContainer/Character/PictureBack/Holder/CharacterSprite
@onready var sprite_holder = $HBoxContainer/Character/PictureBack/Holder
@onready var gear_slots: Array = $HBoxContainer/Gear.get_children()
@onready var skill_slots: Array = $HBoxContainer/Skills.get_children()
@onready var exp_bar: TextureProgressBar = $HBoxContainer/Character/CenterContainer/ExpProgressBar
@onready var hp_bar: TextureProgressBar = $HBoxContainer/Character/CenterContainer2/HealthBar
var current_character: Unit

func update_gear(gear: Array[Item]):
	pass 

func update_skills():
	pass 

func update_bars():
	pass 

func update_repr():
	name_label.text = current_character.name
	if sprite_holder.get_child_count():
		sprite_holder.remove_child(sprite)
	sprite = current_character.sprite_for_outline.duplicate()
	sprite.centered = false
	sprite.offset = Vector2i(0, 24)
	sprite_holder.add_child(sprite)
	print("done")
	
	pass 
	

func update():
	#update_gear()
	#update_skills()
	#update_bars()
	update_repr()
	pass



func change_character(character: PackedScene):
	current_character = character.instantiate()
	print("changed displayed character to <",current_character.name ,">" )
	update()
	pass
