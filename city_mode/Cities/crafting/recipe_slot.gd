extends PanelContainer
 
var item: Item = null:
	set(value):
		item = value
 
		if value != null:
			$TextureRect.texture = value.texture
		else:
			$TextureRect.texture = null

var num: int = 0:
	set(value):
		num = value
		
		if value > 1:
			$back/Label.text = str(value)
		else:
			$back/Label.text = ""
 
#func enable(value = true):
	#$Panel.show_behind_parent = value
	#return value
