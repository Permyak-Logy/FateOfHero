extends PanelContainer

class_name TradeSlot

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

func get_preview():
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture_rect.texture
	var preview = Control.new()
	preview.add_child(preview_texture)
	
	return preview

func _get_drag_data(_at_position):
	if item != null:
		set_drag_preview(get_preview())
		return self

func _can_drop_data(_pos, data):
	return data is BuySlot

func _drop_data(at_position, data):
	$"..".inventory.insert(data.item, 1)
	$"..".update()
	$"../../../Trade/VBoxContainer/buy".buys.remove(data.item, 1)
	$"../../../Trade/VBoxContainer/buy".update()
	$"../../../Trade/VBoxContainer/trade".check()
