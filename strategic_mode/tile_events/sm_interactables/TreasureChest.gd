extends AreaBasedInteractable

@onready var game: Game = get_tree().root.get_child(0)
@export var contents: Dictionary
var is_open = false

func _ready():
	print(contents)

func activate():
	assert(contents != null)
	if not is_open:
		return
	for reward in contents.keys():
		game.strat_map.player.inventory.insert(reward, contents[reward])
	remove()

func open():
	sprite.frame = 1
	is_open = true

func close():
	sprite.frame = 0
	is_open = false
