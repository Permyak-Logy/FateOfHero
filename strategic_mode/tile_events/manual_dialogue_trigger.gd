extends "res://strategic_mode/tile_events/TileEvent.gd"

"""
Allows player to start a dialogue when near the tile and action button is pressed 
may be used for teleporters, obelisks or abything else 
To use it you should create a dialog
"""
@export var dialogue: Dialogue
@export var do_destroy_on_exit: bool = false
@export var texture: Texture2D

@onready var game: Game = get_tree().root.get_child(0)
@onready var area: Area2D = $Area2D
@onready var spite: Sprite2D = $Sprite2D
@onready var strat_map: StratMap = get_tree().root.get_child(0).strat_map
@onready var DialogueGUIRes = preload("res://GUI/dialogue/dialogue_gui.tscn")

var dialogue_gui: DialogueGUI
var player_present = false
# it won't be triggered on contact as EventCollider is disabled
func activate():
	assert(dialogue != null, "you'va forgotten to set the dialog")
	dialogue_gui = DialogueGUIRes.instantiate()
	strat_map.gui.add_child(dialogue_gui)
	dialogue_gui.change_dialogue(dialogue)
	dialogue_gui.dialogue_finished.connect(on_dialogue_finished)
	strat_map.pause()

func _ready():
	spite.texture = texture

func _input(event):
	if event.is_action_pressed("activate") and player_present:
		activate()

func on_dialogue_finished():
	strat_map.gui.remove_child(dialogue_gui)
	strat_map.unpause()
	if do_destroy_on_exit:
		remove()
	pass


func _on_area_2d_body_exited(body):
	if not is_instance_of(body, Player): return	
	player_present = false
	
func _on_area_2d_body_entered(body):
	if not is_instance_of(body, Player): return
	player_present = true
