class_name MainMenu extends Control

@onready var campaign_button: Button = $Menu/Campaign
@onready var infinite_button: Button = $Menu/Infinite
@onready var exit_button: Button = $Menu/Exit
@onready var save_menu_container: Control = $SaveMenuComtainer

var SaveMenuRes = preload("res://GUI/main_menu/save_menu.tscn") 

func show_save_menu(saves: Array[PackedScene]):
	var save_menu: SaveMenu = SaveMenuRes.instantiate()
	save_menu_container.add_child(save_menu)
	save_menu.prep(saves)

func _on_campaign_pressed():
	show_save_menu([])

func _on_infinite_pressed():
	show_save_menu([])


func _on_exit_pressed():
	pass
