extends Control

var is_open:bool = false 

signal inventory_opened
signal inventory_closed

@onready var inventory: Inventory = preload("res://inventory/global_inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var ItemStackReprClass = preload("res://inventory/item_stack_repr.tscn")

var item_stack_in_hand: ItemStackRepr

func _ready():
	connectSlots()
	visible = false
	update()

func connectSlots():
	for slot in slots:
		var callable = Callable(on_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)
	

func update():
	for slot in slots:
		slot.item_stack_repr = null
		slot.update()
	var item_stacks = inventory.get_item_stacks()
	for i in range(min(item_stacks.size(), slots.size())):
		var item_stack: ItemStack = item_stacks[i]
		var item_stack_repr: ItemStackRepr = slots[i].item_stack_repr
		if not item_stack_repr:
			item_stack_repr = ItemStackReprClass.instantiate()
			slots[i].insert(item_stack_repr)
		item_stack_repr.item_stack = item_stack
		item_stack_repr.update()
	
	for slot in slots:
		slot.update()
		
func open():
	is_open = true 
	visible = true
	inventory_opened.emit()
	update()
	
func close():
	is_open = false 
	visible = false
	inventory_closed.emit()

func on_slot_clicked(slot):
	if slot.is_empty() and item_stack_in_hand and item_stack_in_hand.item_stack:
		var item_stack: ItemStack = item_stack_in_hand.item_stack
		#item_stack_in_hand.top_level = false
		remove_child(item_stack_in_hand)
		item_stack_in_hand = null 
		inventory.insert(item_stack.item, item_stack.size)
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
