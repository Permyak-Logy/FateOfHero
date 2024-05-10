extends PanelContainer

class_name CraftingSlot
 
@onready var texture_rect = $TextureRect
@onready var item_number = $Label
 
@export var item : Item = null:
	set(value):
		item = value
 
		if value != null:
			$TextureRect.texture = value.texture
			$back.frame = 1
		else:
			$TextureRect.texture = null
			$back.frame = 0

@export var stack : int = 0:
	set(value):
		stack = value
		
		if value != null and value != 0:
			$Label.text = str(value)
		else:
			$Label.text = ''

@export var max_stack : int = 0:
	set(value):
		max_stack = value 
#func get_preview():
	#var preview_texture = TextureRect.new()
	#var preview_number = Label.new()
	#preview_texture.texture = texture_rect.texture
	#preview_number.text = item_number.text
 #
	#var preview = Control.new()
	#preview.add_child(preview_texture)
	#preview.add_child(preview_number)
 #
	#return preview
#
#func _get_drag_data(_at_position):
	#set_drag_preview(get_preview())
	#return self
 #
#func _can_drop_data(_pos, data):
	#return data is CraftingSlot
 #
#func _drop_data(_at_position, data):
	#var temp1 = item
	#var temp2 = stack
	#item = data.item
	#stack = data.stack
	#data.item = temp1
	#data.stack = temp2
