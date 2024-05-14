class_name InventoryTrashSlot extends InventorySlot

func insert(isr: ItemStackRepr):
	if item_stack_repr:
		container.remove_child(item_stack_repr)
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
	return true
