extends Panel


class_name ItemStackRepr 

@onready var itemSprite: Sprite2D = $item
@onready var size_label: Label = $Label


var item_stack: ItemStack

func update():
	if not item_stack or not item_stack.item:return
		
	itemSprite.visible = true 
	itemSprite.texture = item_stack.item.texture
	size_label.visible = true 
	size_label.text = str(item_stack.size)
