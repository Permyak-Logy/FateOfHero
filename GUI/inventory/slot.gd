class_name InventorySlot extends Button

"""
The slot class
reports when hovered
"""

@onready var backgroundSprite: Sprite2D = $background
@onready var container: CenterContainer = $CenterContainer

var item_stack_repr: ItemStackRepr 

signal HoveringInventorySlot(slot: InventorySlot)
signal UnhoveringInventorySlot(slot: InventorySlot)

func insert(isr: ItemStackRepr):
	item_stack_repr = isr 
	backgroundSprite.frame = 1
	container.add_child(isr)
	update()

func take_item():
	var item_stack = item_stack_repr
	container.remove_child(item_stack_repr)
	item_stack_repr = null 
	backgroundSprite.frame = 0 
	return item_stack

func update():
	if item_stack_repr:
		backgroundSprite.frame = 1
		if not item_stack_repr in container.get_children():
			container.add_child(item_stack_repr)
	else:
		backgroundSprite.frame = 0
		if  container.get_children():
			container.remove_child(container.get_children()[0])

func is_empty():
	return not item_stack_repr

func _on_mouse_entered():
	HoveringInventorySlot.emit(self)

func _on_mouse_exited():
	UnhoveringInventorySlot.emit(self)
