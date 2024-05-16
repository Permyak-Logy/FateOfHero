class_name RunePlacementGUI extends Control

@onready var ItemStackReprClass = preload("res://inventory/item_stack_repr.tscn")
@onready var game: Game = get_tree().root.get_child(0)
@onready var inventory: Inventory = game.strat_map.player.inventory
var place_inventory: MicroInventory = null

@onready var inventory_panel: InventoryPanel = $HBoxContainer/InventoryPanel
@onready var placement_panel: RunePlacementPanel = $HBoxContainer/PlacementPanel

@onready var inv_slots = inventory_panel.slots


signal done

var item_stack_in_hand: ItemStackRepr
var item_stack_in_hand_origin: InventorySlot
var hovering_slot: InventorySlot = null
var is_done = false


func _ready():
	assert(place_inventory != null, "You forgot to pass place's inventory")
	connect_inventory_slots()
	placement_panel.rune_slot.HoveringInventorySlot.connect(on_slot_hovered)
	placement_panel.rune_slot.UnhoveringInventorySlot.connect(on_slot_unhovered)
	if place_inventory.contents:
		var isr: ItemStackRepr = ItemStackReprClass.instantiate()
		placement_panel.current_rune = isr
		placement_panel.update()
		isr.item_stack = ItemStack.create(place_inventory.contents.item, place_inventory.contents.size)
		isr.update()
	update()

func connect_inventory_slots():
	for slot in inv_slots:
		slot.HoveringInventorySlot.connect(on_slot_hovered)
		slot.UnhoveringInventorySlot.connect(on_slot_unhovered)

func update():
	var item_stacks: Array[ItemStack] = inventory.get_item_stacks()
	inventory_panel.update(item_stacks)
	placement_panel.update()

func update_item_in_hand():
	if not item_stack_in_hand: return
	item_stack_in_hand.global_position = get_global_mouse_position() - item_stack_in_hand.size / 2

func on_slot_hovered(slot: InventorySlot):
	hovering_slot = slot

func on_slot_unhovered(slot: InventorySlot):
	hovering_slot = null

func put_item_in_inv():
	if not (item_stack_in_hand and item_stack_in_hand.item_stack):
		return
	var item_stack: ItemStack = item_stack_in_hand.item_stack
	var remaining = inventory.insert(item_stack.item, item_stack.size)
	if !remaining:
		remove_child(item_stack_in_hand)
		item_stack_in_hand = null 
	else:
		print("remaining")
		item_stack_in_hand.item_stack.size = remaining
	update()

func take_item_from_inv_slot(slot: InventorySlot):
	if item_stack_in_hand:
		return
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

func put_item_in_place() -> bool:
	if placement_panel.current_rune:
		return false
	if not item_stack_in_hand.item_stack.item.name.begins_with("rune"):
		return false
	remove_child(item_stack_in_hand)
	placement_panel.current_rune = item_stack_in_hand
	place_inventory.insert_is(item_stack_in_hand.item_stack)
	item_stack_in_hand = null
	update()
	return true

func take_from_place():
	if item_stack_in_hand:
		return 
	if not placement_panel.current_rune:
		return
	item_stack_in_hand = placement_panel.rune_slot.take_item()
	place_inventory.remove(item_stack_in_hand.item_stack.item, item_stack_in_hand.item_stack.size)
	add_child(item_stack_in_hand)
	placement_panel.current_rune = null 
	update()

func put_to(slot: InventorySlot):
	if slot.name.begins_with("Slot"):
		put_item_in_inv()
	else:
		if not put_item_in_place():
			put_item_in_inv()
	

func take_from(slot:InventorySlot):
	if hovering_slot.name.begins_with("Slot"):
		take_item_from_inv_slot(hovering_slot)
	else:
		take_from_place()
	 

func _input(event):
	update_item_in_hand()
	#if event.is_action_pressed("escape"):
		#done.emit()
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

func open():
	pass

func close():
	done.emit()
