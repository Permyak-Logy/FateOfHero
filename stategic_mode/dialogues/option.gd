class_name DialogueOption extends Node

@export var msg: String 
@export var next_dialogue: Dialogue

# will be usefull in many situations
@onready var game: Game = get_tree().root.get_child(0)

func activate():
	"""
	This function is called when option is chosen
	By default does nothing
	"""
	pass
