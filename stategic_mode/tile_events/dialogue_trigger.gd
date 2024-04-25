extends "res://stategic_mode/tile_events/TileEvent.gd"

"""
starts a dialogue on contact
will disapear when dialog is over
"""

@export var dialogue: Dialogue
@export var texture: Texture2D

@onready var sprite = $Sprite2D
@onready var strat_map: StratMap = get_tree().root.get_child(0).strat_map
@onready var DialogueGUIRes = preload("res://GUI/dialogue/dialogue_gui.tscn")
var dialogue_gui: DialogueGUI

func activate():
	assert(dialogue != null, "you'va forgotten to set the dialog")
	dialogue_gui = DialogueGUIRes.instantiate()
	strat_map.gui.add_child(dialogue_gui)
	dialogue_gui.change_dialogue(dialogue)
	dialogue_gui.dialogue_finished.connect(on_dialogue_finished)
	strat_map.pause()

func on_dialogue_finished():
	strat_map.gui.remove_child(dialogue_gui)
	strat_map.unpause()
	remove()
	pass

func _ready():
	sprite.texture = texture
	
