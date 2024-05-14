class_name InventoryGUI extends Control

"""
Root of inventory gui. It is also a controller in this this gui
other scenes are just views
"""

var is_open:bool = false 

signal inventory_opened
signal inventory_closed

@onready var ItemStackReprClass = preload("res://inventory/item_stack_repr.tscn")
var game: Game
var inventory: Inventory

@onready var inventory_panel: InventoryPanel = $HBoxContainer/VBoxContainer/InventoryPanel 
@onready var character_selection_panel: CharacterSelectionPanel = $HBoxContainer/VBoxContainer/CharacterSelectionPanel
@onready var character_panel: CharacterPanel = $HBoxContainer/CharacterPanel


@onready var inv_slots = inventory_panel.slots
# these will be defined in `_ready()`
var character_buttons: Array = []
var gear_slots: Array = []
var ability_slots: Array = []
var active_char_id: int = 0
# these won't
var item_stack_in_hand: ItemStackRepr
var item_stack_in_hand_origin: InventorySlot
var hovering_slot: InventorySlot = null

const DESCRIPTION_OFFSET: Vector2 = Vector2(-260, -100)
const DESCTIPTION_DELAY: float = 2.4
const ItemDescriptionPanelRes: PackedScene = preload("res://GUI/inventory/description_panel.tscn")
var description: ItemDesctiptionPanel
var description_timer: Timer

func _ready():
	connect_inventory_slots()
	visible = false

func reinit():
	game = get_tree().root.get_child(0)
	inventory = game.strat_map.player.inventory
	
	character_buttons = []
	gear_slots = []
	ability_slots = []
	active_char_id = 0
	
	character_selection_panel.init(inventory.characters.size())
	character_buttons = character_selection_panel.buttons
	character_panel.change_character(inventory.characters[0])
	gear_slots = character_panel.gear_slots
	ability_slots = character_panel.ability_slots
	connect_buttons()
	connect_character_slots()
	update()

func connect_inventory_slots():
	for slot in inv_slots:
		slot.HoveringInventorySlot.connect(on_slot_hovered)
		slot.UnhoveringInventorySlot.connect(on_slot_unhovered)

func connect_character_slots():
	for slot in gear_slots + ability_slots:
		slot.HoveringInventorySlot.connect(on_slot_hovered)
		slot.UnhoveringInventorySlot.connect(on_slot_unhovered)

func connect_buttons():
	print("binding buttons")
	for button in character_buttons:
		print("char - ", button.id, " - ", inventory.characters[button.id])
		var callable = Callable(on_char_button_pressed)
		callable = callable.bind(button.id)
		button.pressed.connect(callable)
		

func update():
	var item_stacks: Array[ItemStack] = inventory.get_item_stacks()
	inventory_panel.update(item_stacks)
	character_panel.update()
	
	
func open():
	reinit()
	is_open = true 
	visible = true
	inventory_opened.emit()
	
func close():
	hide_description()
	inventory.characters[active_char_id] = character_panel.pack_character()
	is_open = false 
	visible = false
	inventory_closed.emit()

func on_char_button_pressed(id: int):
	if id == active_char_id:
		return
	inventory.characters[active_char_id] = character_panel.change_character(inventory.characters[id])
	gear_slots = character_panel.gear_slots
	ability_slots = character_panel.ability_slots
	connect_character_slots()
	active_char_id = id
	print("changed to character ", id)

func update_item_in_hand():
	if not item_stack_in_hand: return
	item_stack_in_hand.global_position = get_global_mouse_position() - item_stack_in_hand.size
	if description:
		description.position = get_global_mouse_position() + DESCRIPTION_OFFSET


func put_item_in_inv():
	if not (item_stack_in_hand and item_stack_in_hand.item_stack):
		return false
	var item_stack: ItemStack = item_stack_in_hand.item_stack
	var remaining = inventory.insert(item_stack.item, item_stack.size)
	if !remaining:
		remove_child(item_stack_in_hand)
		item_stack_in_hand = null 
	else:
		print("remaining")
		item_stack_in_hand.item_stack.size = remaining
	update()
	

func take_item_from_inv_slot(slot: InventorySlot) -> bool:
	if item_stack_in_hand:
		return false
	if not slot.item_stack_repr:
		return false
	item_stack_in_hand = slot.item_stack_repr
	slot.container.remove_child(item_stack_in_hand)
	add_child(item_stack_in_hand)
	slot.item_stack_repr = null
	var item_stack = item_stack_in_hand.item_stack
	inventory.remove(item_stack.item, item_stack.size)
	update()
	update_item_in_hand()
	return true

func put_item_to_char_slot(slot: InventorySlot) -> int:
	if not (slot.is_empty() and item_stack_in_hand and item_stack_in_hand.item_stack):
		return false
	var item_stack: ItemStack = item_stack_in_hand.item_stack
	if not is_instance_of(item_stack.item, Gear):
		return false
	var fit = character_panel.current_character.inventory.use(item_stack)
	character_panel.current_character.reload_all_mods()
	print("equipped: ", item_stack.item.name, " size:", item_stack.size)
	item_stack_in_hand.item_stack.size -= fit
	if item_stack_in_hand.item_stack.size == 0:
		remove_child(item_stack_in_hand)
		item_stack_in_hand = null
	update()
	return item_stack_in_hand != null


func take_item_form_char_slot(slot: InventorySlot) -> bool:
	if item_stack_in_hand:
		return false
	if not slot.item_stack_repr:
		return false
	item_stack_in_hand = slot.item_stack_repr
	slot.container.remove_child(item_stack_in_hand)
	add_child(item_stack_in_hand)
	slot.item_stack_repr = null
	var item_stack = item_stack_in_hand.item_stack
	var fit = character_panel.current_character.inventory.unuse(item_stack)
	assert(item_stack.size == fit, "Ошибка в снятии предмета")
	character_panel.current_character.reload_all_mods()
	update()
	update_item_in_hand()
	return true

func put_to(slot: InventorySlot):
	var success = true
	if slot.name.begins_with("Slot"):
		put_item_in_inv()
	else:
		if not put_item_to_char_slot(slot):
			put_item_in_inv()

func take_from(slot:InventorySlot):
	if hovering_slot.name.begins_with("Slot"):
		return take_item_from_inv_slot(hovering_slot)
	else:
		return take_item_form_char_slot(hovering_slot)
	 

func _input(event):
	update_item_in_hand()
	if event.is_action_pressed("lmb"):
		if not hovering_slot:
			return
		take_from(hovering_slot)
		item_stack_in_hand_origin = hovering_slot
	
	if event.is_action_released("lmb"):
		if not item_stack_in_hand:
			return
		var target_slot = hovering_slot
		if not hovering_slot or not hovering_slot.is_empty():
			target_slot = item_stack_in_hand_origin
		put_to(target_slot)

func show_description(item: Item):
	hide_description()
	if not item: return
	description = ItemDescriptionPanelRes.instantiate() 
	description.item = item
	add_child(description)
	description.top_level = true 
	description.mouse_filter = 2
	description.position = get_global_mouse_position() + DESCRIPTION_OFFSET

func hide_description():
	if not description:
		return
	remove_child(description)
	remove_child(description_timer)
	description_timer = null
	description = null

func on_slot_hovered(slot: InventorySlot):
	hovering_slot = slot
	if not slot.item_stack_repr:
		return
	description_timer = Timer.new()
	var callable = Callable(show_description)
	callable = callable.bind(hovering_slot.item_stack_repr.item_stack.item)
	description_timer.timeout.connect(callable)
	add_child(description_timer)
	description_timer.start(DESCTIPTION_DELAY)

func on_slot_unhovered(slot: InventorySlot):
	hovering_slot = null
	hide_description()
