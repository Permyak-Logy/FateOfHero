extends "res://stategic_mode/tile_events/TileEvent.gd"


@onready var game: Game = get_tree().root.get_child(0)

func activate():
	game.to_city_mode()
	remove()
