class_name StratMapMenu extends Control

signal leave_menu
@onready var game: Game = get_tree().root.get_child(0)

func _ready():
	visible = false

func _on_continue_pressed():
	game.strat_map.gui.close_gui()

func _on_exit_pressed():
	game.strat_map.gui.close_gui()
	game.to_main_menu()

func open():
	visible = true

func close():
	visible = false
