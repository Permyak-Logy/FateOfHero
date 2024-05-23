class_name PuzzleActivator extends TileEvent

var game: Game

@export var puzzle: PackedScene
@export var success_rewards: Array[ItemStack] = []

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
	game = get_tree().root.get_child(0)
	var puzzle_scene: BasePuzzle = puzzle.instantiate()
	puzzle_scene.rewards = success_rewards
	puzzle_scene.solved.connect(on_solved)
	game.external_puzzle_container.add_child(puzzle_scene)
	game.to_puzzle_mode()

func on_solved(rewards: Array[ItemStack]):
	remove()
	for reward in rewards:
		game.strat_map.player.inventory.insert(reward.item, reward.size)
	for child in game.external_puzzle_container.get_children():
		game.external_puzzle_container.remove_child(child)
		child.queue_free()
	game.to_strat_mode()
	pass

func on_failed(rewards: Array[ItemStack]):
	game.strat_map.player.backtrack()
	game.to_strat_mode()
