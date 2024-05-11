class_name InitCharInfoPanel extends Panel

signal init_char_chosen(char: PackedScene)

@export var presented_character: PackedScene

@onready var name_label: Label = $VBoxContainer/Name
@onready var descr_box: RichTextLabel = $VBoxContainer/Description
@onready var select_button: Button = $VBoxContainer/Select

var character: Unit

func turn_off():
	name_label.text = "work in progress"
	descr_box.text = ""
	select_button.disabled = true


func _ready():
	if not presented_character:
		turn_off()
		return
	character = presented_character.instantiate() 
	add_child(character)
	character.visible = false
	name_label.text = character.name
	descr_box.text = character.editor_description

func _on_select_pressed():
	remove_child(character)
	init_char_chosen.emit(presented_character)
