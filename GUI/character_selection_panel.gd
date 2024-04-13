extends NinePatchRect

class_name CharacterSelectionPanel

@onready var container = $HBoxContainer
@onready var button_scene = preload("res://GUI/character_button.tscn")
var buttons = []

func init(char_count: int):
	for i in range(char_count):
		var btn = button_scene.instantiate()
		container.add_child(btn)
		btn.init(i)
	buttons = container.get_children()
