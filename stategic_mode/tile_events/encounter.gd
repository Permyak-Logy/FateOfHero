extends "res://stategic_mode/tile_events/TileEvent.gd"

class_name Encounter
@onready var sprite: Sprite2D = $Sprite2D
@onready var game: Game = get_tree().root.get_child(0)
@onready var inventory: Inventory = preload("res://inventory/global_inventory.tres")

@export var texture: Texture2D 
@export var enemies: Array[PackedScene]

"""
represents encounter
you must put an instance of this scene into the strat_map scene
then you should define opponents in enemies array 
(just set size and drag the scene into the slots)
and texture 
(again, just drag the texture into the slot)
"""

func _ready():
	sprite.texture = texture
	pass

func activate():
	var characters = inventory.characters
	game.tactical_map.reinit(characters, enemies)
	game.to_tact_mode()
	game.tactical_map.finish.connect(on_finish_tactical_map)
	
func on_finish_tactical_map(): # TODO: characters: Array[PackedScene], result):
	#inventory.characters = characters
	game.to_strat_mode()
	remove()
