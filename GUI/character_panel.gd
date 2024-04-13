extends NinePatchRect

class_name CharacterPanel


@onready var name_label: Label = $HBoxContainer/Character/Name
@onready var sprite: Sprite2D = $HBoxContainer/Character/PictureBack/Holder/CharacterSprite
@onready var sprite_holder: CenterContainer = $HBoxContainer/Character/PictureBack/Holder
@onready var gear_holder: VBoxContainer = $HBoxContainer/Gear
@onready var ability_holder: VBoxContainer = $HBoxContainer/Skills
@onready var exp_bar: TextureProgressBar = $HBoxContainer/Character/CenterContainer/ExpProgressBar
@onready var hp_bar: TextureProgressBar = $HBoxContainer/Character/CenterContainer2/HealthBar
@onready var exp_label = $HBoxContainer/Character/CenterContainer/ExpProgressBar/Label
@onready var hp_label = $HBoxContainer/Character/CenterContainer2/HealthBar/Label

var current_character: Unit = null
var gear_slots = []
var ability_slots = []
var t = 0

@onready var ItemStackReprClass = preload("res://inventory/item_stack_repr.tscn")
@onready var special_slots = {
	Gear.Type.Head : preload("res://GUI/slot_variations/head_slot.tscn"),
	Gear.Type.Body : preload("res://GUI/slot_variations/body_slot.tscn"),
	Gear.Type.Hands : preload("res://GUI/slot_variations/arm_slot.tscn"),
	Gear.Type.Legs : preload("res://GUI/slot_variations/legs_slot.tscn"),
	Gear.Type.Ability : preload("res://GUI/slot_variations/ability_slot.tscn")
}

func remake_gear_slots():
	for child in gear_holder.get_children():
		gear_holder.remove_child(child)
	for type in current_character.inventory.gear_slots:
		for i in range(current_character.inventory.gear_slots[type]):
			var slot = special_slots[type].instantiate()
			gear_holder.add_child(slot)
	gear_slots = gear_holder.get_children()
	

func remake_ability_slots():
	for child in ability_holder.get_children():
		ability_holder.remove_child(child)
	for i in range(current_character.inventory.max_abilities):
		var slot = special_slots[Gear.Type.Ability].instantiate()
		ability_holder.add_child(slot)
	ability_slots = ability_holder.get_children()
	
func update_gear():
	print("updating gear")	
	for type in current_character.inventory.gear_slots:
		print(" - ", type)
		for item in current_character.inventory.get_gears(type):
			print("-", item)
			var item_stack = ItemStack.new(item, 1)
			var isr = ItemStackReprClass.instantiate()
			isr.item_stack = item_stack
			isr.update()

func update_abilities():
	print("updating abilities")
	for item in current_character.inventory.get_abilities():
		print("-", item)		
		var slot = special_slots[Gear.Type.Ability].instantiate()
		var item_stack = ItemStack.new(item, 1)
		var isr = ItemStackReprClass.instantiate()
		isr.item_stack = item_stack
		isr.update()
		ability_holder.add_child(slot)
	ability_slots = ability_holder.get_children()
	
	
	


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
	update_gear()
	update_abilities()
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
	remake_gear_slots()
	remake_ability_slots()
	print("changed displayed character to <",current_character.name ,">" )
	update()
	return old_char
	
func _process(delta):
	t += delta
	if t > 1:
		sprite.frame = 1 + (sprite.frame  % 3) 
		t = 0
