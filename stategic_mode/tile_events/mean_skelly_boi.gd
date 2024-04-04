extends "res://stategic_mode/tile_events/TileEvent.gd"


@onready var game: Game = get_tree().root.get_child(0)
@onready var inventory: Inventory = preload("res://inventory/global_inventory.tres")

@export var enemies: Array[Unit]

func activate():
	inventory.set_def_chars()
	var characters = inventory.characters
	game.tactical_map.reinit(characters)
	game.to_tact_mode()
	remove()
