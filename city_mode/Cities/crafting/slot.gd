extends Button

class_name Slot
 
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

