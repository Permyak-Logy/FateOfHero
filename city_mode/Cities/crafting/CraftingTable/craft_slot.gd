class_name CraftSlot extends PanelContainer

#@onready var game: Game = get_tree().root.get_child(0)
#@onready var global_inventory : Inventory = game.strat_map.player.inventory
@export var global_inventory: Inventory = null

var item : Item = null:
	set(value):
		item = value
		
		if value != null:
			$TextureRect.texture = item.texture
			$Back.frame = 1
		else:
			$TextureRect.texture = null
			$Back.frame = 0

var stack : int = 0:
	set(value):
		stack = value
		
		if value > 1:
			$Label.text = str(stack)
		else:
			$Label.text = ""

func get_preview():
	var preview_texture = TextureRect.new()
	preview_texture.texture = $TextureRect.texture
	var preview = Control.new()
	preview.add_child(preview_texture)
	
	return preview

func _get_drag_data(_at_position):
	if item != null:
		set_drag_preview(get_preview())
		return self

func _can_drop_data(_pos, data):
	return data is CraftingSlot and (item == null or data.item == item)
 
func _drop_data(_at_position, data):
	if data.item == item:
		stack += 1
	else:
		item = data.item
		stack = 1
	global_inventory.remove(item, 1)
	$"../../../inventory/inventoryGrid".update()
	$"..".check()

func remove_item():
	if stack == 1:
		item = null
	stack -= 1
