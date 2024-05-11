class_name MainMenu extends Control

@onready var continue_button: Button = $Menu/Continue
@onready var campaign_button: Button = $Menu/Campaign
@onready var infinite_button: Button = $Menu/Infinite
@onready var exit_button: Button = $Menu/Exit
@onready var save_menu_container: Control = $SaveMenuComtainer

@onready var game: Game = get_tree().root.get_child(0)


func _ready():
	infinite_button.disabled = true
	if not ResourceLoader.exists("res://save/save.tscn"):
		continue_button.disabled = true


func _on_continue_pressed():
	game.load_save()
	game.to_strat_mode()
	pass

func _on_campaign_pressed():
	game.new_save()
	game.to_strat_mode()
	pass

func _on_infinite_pressed():
	pass

func _on_exit_pressed():
	get_tree().quit()
	pass


