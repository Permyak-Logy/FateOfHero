extends NinePatchRect

class_name CharacterPanel

"""
Panel on the right that represents character and their gear
"""

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
var slots = {
	Gear.Type.Head : [],
	Gear.Type.Body : [],
	Gear.Type.Hands : [],
	Gear.Type.Legs : [],
	Gear.Type.Ability : [],
}
var t = 0

@onready var ItemStackReprClass = preload("res://inventory/item_stack_repr.tscn")
@onready var special_slots = {
	Gear.Type.Head : preload("res://GUI/inventory/slot_variations/head_slot.tscn"),
	Gear.Type.Body : preload("res://GUI/inventory/slot_variations/body_slot.tscn"),
	Gear.Type.Hands : preload("res://GUI/inventory/slot_variations/arm_slot.tscn"),
	Gear.Type.Legs : preload("res://GUI/inventory/slot_variations/legs_slot.tscn"),
	Gear.Type.Ability : preload("res://GUI/inventory/slot_variations/ability_slot.tscn")
}

func remake_gear_slots():
	for child in gear_holder.get_children():
		gear_holder.remove_child(child)
	for type in Gear.Type.values():
		if type == Gear.Type.Ability:
			continue
		for i in range(current_character.inventory.gear_slots.get(type, InventoryComponent.DEFAULT_COUNT_SLOTS)):
			var slot = special_slots[type].instantiate()
			gear_holder.add_child(slot)
			slots[type].append(slot)
	gear_slots = gear_holder.get_children()
	

func remake_ability_slots():
	for child in ability_holder.get_children():
		ability_holder.remove_child(child)
	for i in range(current_character.inventory.gear_slots.get(Gear.Type.Ability, InventoryComponent.DEFAULT_COUNT_SLOTS)):
		var slot = special_slots[Gear.Type.Ability].instantiate()
		ability_holder.add_child(slot)
		slots[Gear.Type.Ability].append(slot)
		
	ability_slots = ability_holder.get_children()

func remake_stots():
	slots.clear()
	slots[Gear.Type.Head] = []
	slots[Gear.Type.Body] = []
	slots[Gear.Type.Hands] = []
	slots[Gear.Type.Legs] = []
	slots[Gear.Type.Ability] = []
	remake_gear_slots()
	remake_ability_slots()
	
func update_gear():
	for slot in gear_slots:
		slot.item_stack_repr = null
		slot.update()
	
	for type in Gear.Type.values():
		if type == Gear.Type.Ability:
			continue
		var i = 0
		for item in current_character.inventory.get_gears(type):
			var item_stack = ItemStack.new(item, 1)
			var isr = ItemStackReprClass.instantiate()
			slots[type][i].insert(isr)
			isr.item_stack = item_stack
			isr.update()
			i += 1
		

func update_abilities():
	for slot in ability_slots:
		slot.item_stack_repr = null
		slot.update()
	var i = 0
	for item in current_character.inventory.get_abilities():
		var slot = special_slots[Gear.Type.Ability].instantiate()
		var item_stack = ItemStack.new(item, 1)
		var isr = ItemStackReprClass.instantiate()
		isr.item_stack = item_stack
		slots[Gear.Type.Ability][i].insert(isr)
		ability_holder.add_child(slot)
		i += 1
	ability_slots = ability_holder.get_children()

func update_bars():
	hp_bar.max_value = current_character.health.get_max()
	hp_bar.value = current_character.health.cur()
	hp_label.text = str(current_character.health.cur()) + "/" + str(current_character.health.get_max())
	exp_bar.max_value = current_character.expirience.get_exp_to_next_lvl()
	exp_bar.value = current_character.expirience.expirience
	exp_label.text = str(exp_bar.value) + "/" + \
		str(exp_bar.max_value)

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

func print_inventory():
	print(current_character.name, "'s inventory") 
	print(" - Gear.Type.Head:    ", current_character.inventory.get_gears(Gear.Type.Head))
	print(" - Gear.Type.Body:    ", current_character.inventory.get_gears(Gear.Type.Body))
	print(" - Gear.Type.Hands:   ", current_character.inventory.get_gears(Gear.Type.Hands))
	print(" - Gear.Type.Legs:    ", current_character.inventory.get_gears(Gear.Type.Legs))
	print(" - Gear.Type.Ability: ", current_character.inventory.get_gears(Gear.Type.Ability))
	
	

func change_character(character: PackedScene) -> PackedScene:
	var old_char = null
	if current_character:
		print_inventory()
		old_char = PackedScene.new()
		current_character.visible = true
		sprite_holder.remove_child(current_character)
		old_char.pack(current_character)
	
	current_character = character.instantiate()
	current_character.visible = false
	sprite_holder.add_child(current_character)
	
	
	
	
	remake_stots()
	print("changed displayed character to <",current_character.name ,">" )
	update()
	return old_char
	
func _process(delta):
	if !sprite:
		return
	if sprite.hframes < 3:
		return
	t += delta
	if t > 1:
		sprite.frame = 1 + (sprite.frame  % 3) 
		t = 0
