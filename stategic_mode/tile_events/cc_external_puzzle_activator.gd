extends "res://stategic_mode/tile_events/external_puzzle_activator.gd"

"""
capable of starting a combat encounter
"""

@export var enemies: Array[PackedScene] 



func activate():
	var puzzle_scene: BasePuzzle = puzzle.instantiate()
	puzzle_scene.solved.connect(on_done)
	puzzle_scene.enemies = enemies
	remove()
	game.external_puzzle_container.add_child(puzzle_scene)
	game.to_puzzle_mode()
