extends "res://external_puzzles/puzzles/base_puzzle.gd"

class_name SafePath

@onready var tilemap: TileMap = $TileMap
@onready var player = $player

func start():
	solved.emit()
	pass
