class_name InitialCharacterSelectionPanel extends Control

"""
aggregates panels
"""

@onready var char1_panel: InitCharInfoPanel = $Panel/HBoxContainer/InitCharInfo1
@onready var char2_panel: InitCharInfoPanel = $Panel/HBoxContainer/InitCharInfo2
@onready var char3_panel: InitCharInfoPanel = $Panel/HBoxContainer/InitCharInfo3
@onready var char4_panel: InitCharInfoPanel = $Panel/HBoxContainer/InitCharInfo4
@onready var char5_panel: InitCharInfoPanel = $Panel/HBoxContainer/InitCharInfo5

signal init_char_chosen()
var chosen_char: PackedScene = null

func _ready():
	char1_panel.init_char_chosen.connect(choose)
	char2_panel.init_char_chosen.connect(choose)
	char3_panel.init_char_chosen.connect(choose)
	char4_panel.init_char_chosen.connect(choose)
	char5_panel.init_char_chosen.connect(choose)
	
func choose(char: PackedScene):
	chosen_char = char
	init_char_chosen.emit()

