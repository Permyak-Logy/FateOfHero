class_name CharacterSelectionPanel extends NinePatchRect

"""
Rectangle on the top left
has buttons to switch characters

"""

@onready var container = $HBoxContainer
@onready var button_scene = preload("res://GUI/inventory/character_button.tscn")
var buttons = []

func init(char_count: int):
	for c in container.get_children():
		container.remove_child(c) 
	
	for i in range(char_count):
		var btn = button_scene.instantiate()
		container.add_child(btn)
		btn.init(i)
	buttons = container.get_children()
