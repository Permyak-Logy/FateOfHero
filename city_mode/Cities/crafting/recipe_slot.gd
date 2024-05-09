extends PanelContainer
 
var item: Item = null:
	set(value):
		item = value
 
		if value != null:
			$TextureRect.texture = value.texture
		else:
			$TextureRect.texture = null
 
func enable(value = true):
	$Panel.show_behind_parent = value
	#$back.frame = 1
	return value
 
#func check():
	#var inventory = $HBoxContainer/inventory/inventoryGrid
	#if item != null:
		#return enable(inventory.is_available(item))
