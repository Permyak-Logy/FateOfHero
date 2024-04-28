extends "res://strategic_mode/tile_events/external_puzzle_activator.gd"

class_name CombatCapablePuzzleActivator
"""
represents external puzzle
you must put an instance of this scene into the strat_map scene
then you should define puzzle that will be activated,
(just drag the scene into the slot)
texture,
(again, just drag the texture into the slot)
and  define opponents in enemies array 
(just set size and drag the scene into the slots)

 ! capable of starting a combat encounter
 ! requires enemies array defined
"""

@export var enemies: Array[PackedScene] 



func activate():
	var puzzle_scene: BasePuzzle = puzzle.instantiate()
	assert(puzzle_scene.has_method("set_enemies"), "trying to start a non combat puzzle with CombatCapablePuzzleActivator")
	puzzle_scene.solved.connect(on_done)
	puzzle_scene.set_enemies(enemies)
	remove()
	game.external_puzzle_container.add_child(puzzle_scene)
	game.to_puzzle_mode()
