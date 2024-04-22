class_name InventoryGUI extends Control

var is_open:bool = false 

signal inventory_opened
signal inventory_closed

@onready var ItemStackReprClass = preload("res://inventory/item_stack_repr.tscn")
@onready var inventory: Inventory = preload("res://inventory/global_inventory.tres")

@onready var inventory_panel: InventoryPanel = $HBoxContainer/VBoxContainer/InventoryPanel 
@onready var character_selection_panel: CharacterSelectionPanel = $HBoxContainer/VBoxContainer/CharacterSelectionPanel
@onready var character_panel: CharacterPanel = $HBoxContainer/CharacterPanel


@onready var inv_slots: Array = inventory_panel.slots
# these will be defined in `_ready()`
var character_buttons: Array = []
var gear_slots: Array = []
var ability_slots: Array = []
var active_char_id: int = 0
var item_stack_in_hand: ItemStackRepr

func _ready():
	character_selection_panel.init(inventory.characters.size())
	character_buttons = character_selection_panel.buttons
	character_panel.change_character(inventory.characters[0])
	gear_slots = character_panel.gear_slots
	ability_slots =character_panel.ability_slots
	connect_inventory_slots()
	connect_buttons()
	connect_character_slots()
	visible = false
	update()

func connect_inventory_slots():
	for slot in inv_slots:
		var callable = Callable(on_inventory_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func connect_character_slots():
	for slot in gear_slots + ability_slots:
		var callable = Callable(on_character_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)
	
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
	is_open = true 
	visible = true
	update()
	inventory_opened.emit()
	
func close():
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

func on_inventory_slot_clicked(slot):
	if slot.is_empty() and item_stack_in_hand and item_stack_in_hand.item_stack:
		var item_stack: ItemStack = item_stack_in_hand.item_stack
		var remaining = inventory.insert(item_stack.item, item_stack.size)
		if !remaining:
			remove_child(item_stack_in_hand)
			item_stack_in_hand = null 
		else:
			print("remaining")
			item_stack_in_hand.item_stack.size = remaining
		update()
		return
		
	if not item_stack_in_hand:
		if not slot.item_stack_repr:
			return
		item_stack_in_hand = slot.item_stack_repr
		slot.container.remove_child(item_stack_in_hand)
		add_child(item_stack_in_hand)
		slot.item_stack_repr = null
		var item_stack = item_stack_in_hand.item_stack
		inventory.remove(item_stack.item, item_stack.size)
		update()
		update_item_in_hand()
		return

func on_character_slot_clicked(slot):
	if slot.is_empty() and item_stack_in_hand and item_stack_in_hand.item_stack:
		var item_stack: ItemStack = item_stack_in_hand.item_stack
		if not is_instance_of(item_stack.item, Gear):
			return
		var fit = character_panel.current_character.inventory.use(item_stack.item)
		if fit:
			remove_child(item_stack_in_hand)
			item_stack_in_hand = null 
		update()
		return
		
	if not item_stack_in_hand:
		if not slot.item_stack_repr:
			return
		item_stack_in_hand = slot.item_stack_repr
		slot.container.remove_child(item_stack_in_hand)
		add_child(item_stack_in_hand)
		slot.item_stack_repr = null
		var item_stack = item_stack_in_hand.item_stack
		character_panel.current_character.inventory.unuse(item_stack.item)
		update()
		update_item_in_hand()
		return

func take_item_from_slot(slot):
	item_stack_in_hand = slot.take_item()
	add_child(item_stack_in_hand)
	update_item_in_hand()
	
func insert_item_in_slot(slot):
	var item = item_stack_in_hand
	item_stack_in_hand = null
	slot.insert(item)

func update_item_in_hand():
	if not item_stack_in_hand: return
	item_stack_in_hand.global_position = get_global_mouse_position() - item_stack_in_hand.size / 2
	#item_stack_in_hand.top_level = true
	
	
func _input(_event):
	update_item_in_hand()
