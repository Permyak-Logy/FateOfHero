class_name InitCharInfoPanel extends Panel

signal init_char_chosen(char: PackedScene)

@export var presented_character: PackedScene

@onready var name_label: Label = $VBoxContainer/Name
@onready var descr_box: RichTextLabel = $VBoxContainer/Description
@onready var select_button: Button = $VBoxContainer/Select
@onready var sprite_holder: CenterContainer = $VBoxContainer/SpaceForPicture/PictureBack/Holder

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
	name_label.text = character.unit_name
	descr_box.text = character.editor_description
	
	sprite_holder.add_child(character)
	character.global_position = sprite_holder.global_position + Vector2(60, 120)
	character.play("idle")
	character.toggle_preview(true)

func _on_select_pressed():
	sprite_holder.remove_child(character)
	init_char_chosen.emit(presented_character.duplicate(true))
