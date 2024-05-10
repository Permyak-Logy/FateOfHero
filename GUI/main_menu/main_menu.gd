class_name MainMenu extends Control

@onready var campaign_button: Button = $Menu/Campaign
@onready var infinite_button: Button = $Menu/Infinite
@onready var exit_button: Button = $Menu/Exit
@onready var save_menu_container: Control = $SaveMenuComtainer


func show_save_menu(saves: Array[PackedScene]):
	pass

func _on_continue_pressed():
	pass

func _on_campaign_pressed():
	pass

func _on_infinite_pressed():
	pass

func _on_exit_pressed():
	pass


