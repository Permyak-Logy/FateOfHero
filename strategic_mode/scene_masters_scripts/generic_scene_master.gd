class_name SMPuzzleMaster extends Node2D

"""
Контроллер для пазлов. Это очень стандартная логика
поддерживает произвольное колличество призов и условий
"""
var current_state: Array[bool] = []
var prizes: Array[TileEvent] = []
var enemies: Array[TileEvent] = []
@onready var game: Game = get_tree().root.get_child(0)

func _ready():
	var i = 0
	for node in get_children():
		if is_instance_of(node, Encounter):
			current_state.append(false)
			enemies.append(node)
			var callable = Callable(update_state)
			callable = callable.bind(i)
			callable = callable.bind(true)
			node.removed.connect(callable)
			i+=1
			
		if is_instance_of(node, RuneTileEvent):
			current_state.append(node.rune_inside == node.type)
			node.id = i
			node.state_changed.connect(update_state)
			i+=1
		
		if is_instance_of(node, LeverTileEntity):
			current_state.append(node.state == node.expected_state)
			node.id = i
			node.state_changed.connect(update_state)
			i += 1
			
		if is_instance_of(node, KeystoneTileEvent):
			current_state.append(node.local_inventory.contents != null)
			node.id = i
			node.state_changed.connect(update_state)
			i+=1

		if is_instance_of(node, GateTileEvent):
			prizes.append(node)
		
		if is_instance_of(node, TreasureChest):
			prizes.append(node)
		
	game.strat_map.strat_map_loaded.connect(update)

func update():
	for prize in prizes:
		prize.close()
	if not current_state.has(false):
		for prize in prizes:
			prize.open()

func update_state(id: int, state: bool):
	current_state[id] = state
	update()

