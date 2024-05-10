class_name StratMapGUI extends CanvasLayer
"""
invisible node in the strat map
Any GUI should be it's child.
"""
@onready var inventory: InventoryGUI = $InventoryGUI
@onready var sm_menu: StratMapMenu = $StratMapMenu

signal gui_opened
signal gui_closed

var busy = false
var open_gui = null

func _ready():
	pass

func _input(event):
	if busy:
		return
	
	if open_gui:
		if event.is_action_pressed("escape"):
			close_gui()
		if event.is_action_pressed("inv_button") and is_instance_of(open_gui, InventoryGUI):
			close_gui()
	elif event.is_action_pressed("escape"):
		open(sm_menu)
	elif event.is_action_pressed("inv_button"):
		open(inventory)

func open(gui):
	gui_opened.emit()
	gui.open()
	open_gui = gui

func close_gui():
	gui_closed.emit()
	open_gui.close()
	open_gui = null
