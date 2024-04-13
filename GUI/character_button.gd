extends Button

class_name CharacterButton  

@onready var number = $Sprite2D/Label

var id: int = -1

func init(btn_id: int):
	id = btn_id
	number.text = str(id + 1)
