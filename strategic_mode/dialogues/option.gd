class_name DialogueOption extends Node


"""
class for the dialogue option
you need to make a child of "res://stategic_mode/dialogues/`option.tscn"
if you wosh to make option do something or have it apear only when some 
condition is met you must extend the script; othervice it is not nessasory
"""

@export var msg: String 
@export var next_dialogue: Dialogue

# will be usefull in many situations, hence have it defined here
@onready var game: Game = get_tree().root.get_child(0)

signal dialog_action_done (next_dialogue: Dialogue)
func activate():
	"""
	This function is called when option is chosen
	By default does nothing
	note, that when this function is ran, the strat map is paused
	if you want to do something with the game and it freezes, 
	you likely need to unpause the strat map 
	"""
	dialog_action_done.emit(next_dialogue)
	pass

func is_awailable() -> bool:
	""" 
	This function is called when assebling the dialog window
	If True is returned the option will be shown
	"""
	return true
