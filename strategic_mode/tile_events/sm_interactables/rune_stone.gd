class_name RuneTileEvent extends AreaBasedInteractable

@onready var game: Game = get_tree().root.get_child(0)

@export var type: int 
# is_satisfied
var state: bool = false
var gui: RunePlacementGUI
var RunePlacementGUIRes: PackedScene = preload("res://GUI/rune_placement/rune_placement_gui.tscn")

func activate():
	
	game.strat_map.gui.add_child(gui)
	pass
