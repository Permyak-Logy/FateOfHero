extends "res://strategic_mode/tile_events/TileEvent.gd"

@onready var game: Game = get_tree().root.get_child(0)

@export var puzzle: PackedScene

"""
represents external puzzle
you must put an instance of this scene into the strat_map scene
then you should define puzzle that will be activated 
(just drag the scene into the slot)
and texture 
(again, just drag the texture into the slot)

 ! this activator cannot start a puzzle that might result in a combat encounter
"""

func activate():
	var puzzle_scene: BasePuzzle = puzzle.instantiate()
	puzzle_scene.solved.connect(on_done)
	remove()
	game.external_puzzle_container.add_child(puzzle_scene)
	game.to_puzzle_mode()

func on_done():
	for child in game.external_puzzle_container.get_children():
		game.external_puzzle_container.remove_child(child)
	game.to_strat_mode()
	pass
