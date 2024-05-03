class_name StatCard extends Panel

@onready var plus_btn: Button = $"HBoxContainer/+"
@onready var minus_btn: Button = $"HBoxContainer/-"
@onready var name_label: Label = $HBoxContainer/name
@onready var value_label: Label = $HBoxContainer/value

var component: StatComponent

func set_stat_name(name: String):
	name_label.text = name 
	pass

func set_value(value: int):
	value_label.text = str(value) 
