extends "res://stategic_mode/tile_events/TileEvent.gd"


@onready var game: Game = get_tree().root.get_child(0)
@onready var inventory: Inventory = preload("res://inventory/global_inventory.tres")

@export var enemies: Array[PackedScene]

func activate():
	var characters = inventory.characters
	game.tactical_map.reinit(characters, enemies)
	game.to_tact_mode()
	game.tactical_map.finish.connect(on_finish_tactical_map)
	
func on_finish_tactical_map(): #characters: Array[PackedScene], result): # TODO: Исправить
	# inventory.characters = characters
	game.to_strat_mode()
	remove()
