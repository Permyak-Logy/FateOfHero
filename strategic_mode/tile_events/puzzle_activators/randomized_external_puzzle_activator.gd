class_name RandomizedExternalPuzzleActivator extends CombatCapablePuzzleActivator

var reward_count: int = 3
var enemy_count: int = 5

# dict: ItemStack -> wieght: int
var possible_rewards: Dictionary = {
	ItemStack.create(preload("res://inventory/inventory_consumables/wine.tres"), 1) : 1,
	ItemStack.create(preload("res://inventory/inventory_consumables/tea.tres"), 5) : 10,
	ItemStack.create(preload("res://inventory/inventory_consumables/tea.tres"), 10) : 5,
}
var possible_puzzles: Array[Resource] = [
	preload("res://external_puzzles/puzzles/safe_path/safe_path.tscn"),
	preload("res://external_puzzles/puzzles/stealth_run/stealth_run.tscn"),
]
# dict PackedScene -> wight
var possible_enemies: Dictionary = {
	preload("res://tactical_mode/unit/units/Skeleton/Skeleton.tscn") : 10,
	preload("res://tactical_mode/unit/units/Vedmachok/Vedmachok.tscn") : 3 
}

func sum(arr: Array) -> int:
	var s = 0
	for i in arr:
		s += i
	return s

func activate():
	puzzle = possible_puzzles.pick_random()
	success_rewards = []
	var tc = sum(possible_rewards.values())
	for i in range(reward_count):
		var rroll = randi_range(0, tc)
		var rid = -1
		while rroll > 0 and rid == (possible_rewards.size() - 1):
			rid += 1
			rroll -= possible_rewards.values()[rid]
		success_rewards.append(possible_rewards.keys()[rid] as ItemStack)
	
	enemies = []
	tc = sum(possible_enemies.values())
	for i in range(enemy_count):
		var rroll = randi_range(0, tc)
		var rid = -1
		while rroll > 0 and rid == (possible_enemies.size() - 1):
			rid += 1
			rroll -= possible_enemies.values()[rid]
		enemies.append(possible_enemies.keys()[rid] as PackedScene)
	
	# normal ep
	game = get_tree().root.get_child(0)
	var puzzle_scene: BasePuzzle = puzzle.instantiate()
	assert(puzzle_scene.has_method("set_enemies"), "trying to start a non combat puzzle with CombatCapablePuzzleActivator")
	puzzle_scene.solved.connect(on_solved)
	puzzle_scene.set_enemies(enemies, enemy_level)
	puzzle_scene.rewards = success_rewards
	game.external_puzzle_container.add_child(puzzle_scene)
	game.to_puzzle_mode()

