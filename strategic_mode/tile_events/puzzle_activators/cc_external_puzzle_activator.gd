class_name CombatCapablePuzzleActivator extends PuzzleActivator
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
@export var enemy_level: int = 1:
	set(value):
		if value != null:
			enemy_level = value


func activate():
	game = get_tree().root.get_child(0)
	var puzzle_scene: BasePuzzle = puzzle.instantiate()
	assert(puzzle_scene.has_method("set_enemies"), "trying to start a non combat puzzle with CombatCapablePuzzleActivator")
	puzzle_scene.solved.connect(on_solved)
	puzzle_scene.set_enemies(enemies, enemy_level)
	puzzle_scene.rewards = success_rewards
	game.external_puzzle_container.add_child(puzzle_scene)
	game.to_puzzle_mode()
