class_name ItemDesctiptionPanel extends NinePatchRect

@onready var sprite: Sprite2D = $HBoxContainer/VBoxContainer2/Panel/CenterContainer/Sprite2D
@onready var price_label: Label = $HBoxContainer/VBoxContainer2/Price
@onready var name_label: Label = $HBoxContainer/VBoxContainer/Name
@onready var description_label: RichTextLabel = $HBoxContainer/VBoxContainer/Description

var item: Item

func _ready():
	assert(item, "can't display description of null")
	sprite.texture = item.texture
	name_label.text = item.name
	price_label.text = str(item.price) + "G"
	description_label.text = item.description
