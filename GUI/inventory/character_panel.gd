extends NinePatchRect

class_name CharacterPanel

"""
Panel on the right that represents character and their gear
"""

@onready var name_label: Label = $HBoxContainer/Character/Name
@onready var sprite_holder: CenterContainer = $HBoxContainer/Character/PictureBack/Holder
@onready var gear_holder: VBoxContainer = $HBoxContainer/Gear
@onready var ability_holder: VBoxContainer = $HBoxContainer/Skills
@onready var exp_bar: TextureProgressBar = $HBoxContainer/Character/CenterContainer/ExpProgressBar
@onready var hp_bar: TextureProgressBar = $HBoxContainer/Character/CenterContainer2/HealthBar
@onready var exp_label = $HBoxContainer/Character/CenterContainer/ExpProgressBar/Label
@onready var hp_label = $HBoxContainer/Character/CenterContainer2/HealthBar/Label


var cs: CollisionShape2D
var current_character: Unit = null
var gear_slots = []
var slots = {
	Gear.Type.Head : [],
	Gear.Type.Body : [],
	Gear.Type.Hands : [],
	Gear.Type.Legs : []
}
var ability_slots = []
var t = 0

@onready var ItemStackReprClass = preload("res://inventory/item_stack_repr.tscn")
@onready var special_slots = {
	Gear.Type.Head : preload("res://GUI/inventory/slot_variations/head_slot.tscn"),
	Gear.Type.Body : preload("res://GUI/inventory/slot_variations/body_slot.tscn"),
	Gear.Type.Hands : preload("res://GUI/inventory/slot_variations/arm_slot.tscn"),
	Gear.Type.Legs : preload("res://GUI/inventory/slot_variations/legs_slot.tscn")
}
@onready var special_ability_slot = preload("res://GUI/inventory/slot_variations/ability_slot.tscn")

func remake_gear_slots():
	for child in gear_holder.get_children():
		gear_holder.remove_child(child)
	for type in Gear.Type.values():
		for i in range(current_character.inventory.gear_slots.get(type, InventoryComponent.DEFAULT_COUNT_SLOTS)):
			var slot = special_slots[type].instantiate()
			gear_holder.add_child(slot)
			slots[type].append(slot)
	gear_slots = gear_holder.get_children()
	

func remake_ability_slots():
	for child in ability_holder.get_children():
		ability_holder.remove_child(child)
	for i in range(current_character.inventory.ability_slots):
		var slot = special_ability_slot.instantiate()
		ability_holder.add_child(slot)
		ability_slots.append(slot)

	ability_slots = ability_holder.get_children()

func remake_stots():
	# slots.clear()
	slots[Gear.Type.Head].clear()
	slots[Gear.Type.Body].clear()
	slots[Gear.Type.Hands].clear()
	slots[Gear.Type.Legs].clear()
	ability_slots.clear()
	remake_gear_slots()
	remake_ability_slots()
	
func update_gear():
	for slot in gear_slots:
		slot.item_stack_repr = null
		slot.update()
	
	for type in Gear.Type.values():
		var i = 0
		for gear in current_character.inventory.get_gears(type):
			var item_stack = ItemStack.create(gear, 1)
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
		var item_stack = ItemStack.create(item, item.count if item.consumable else 1)
		var isr = ItemStackReprClass.instantiate()
		ability_slots[i].insert(isr)
		isr.item_stack = item_stack
		isr.update()
		i += 1

func update_bars():
	hp_bar.max_value = current_character.health.get_max()
	hp_bar.value = current_character.health.cur()
	hp_label.text = str(int(current_character.health.cur())) + "/" + str(int(current_character.health.get_max()))
	exp_bar.max_value = current_character.expirience.get_exp_to_next_lvl()
	exp_bar.value = current_character.expirience.expirience
	exp_label.text = str(int(exp_bar.value)) + "/" + \
		str(int(exp_bar.max_value))

func update_repr():
	name_label.text = current_character.unit_name
	var offset = sprite_holder.size
	offset[0] /= 2
	current_character.global_position = sprite_holder.global_position + offset
	current_character.toggle_preview(true)
	

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
	print(" - Gear.Type.Ability: ", current_character.inventory.get_abilities())
	
	

func change_character(character: PackedScene) -> PackedScene:
	var old_char = pack_character() if current_character else null
	
	if current_character:
		sprite_holder.remove_child(current_character)
	
	current_character = character.instantiate()
	cs = current_character.get_node_or_null("CollisionShape2D")
	cs.disabled = true
	sprite_holder.add_child(current_character)
	current_character.play("idle")
	
	remake_stots()
	print("changed displayed character to <", current_character.name, ">" )
	print_inventory()
	update()
	return old_char

func pack_character() -> PackedScene:
	var character = PackedScene.new()
	cs = current_character.get_node_or_null("CollisionShape2D")
	cs.disabled = false
	character.pack(current_character)
	cs.disabled = true
	
	return character
