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
	return value
