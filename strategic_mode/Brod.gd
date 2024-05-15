extends Node

@export var current_state: Array[bool] = []
@onready var gate: GateTileEvent = $Gate2
@onready var lever: LeverTileEntity= $Lever
@onready var encounters: Array[Encounter] = []
func _ready():
	var i = 0
	for node in get_children():
		current_state.append(false)
		if is_instance_of(node, Encounter):
			i+=1
			encounters.append(node)
			var callable = Callable(update_state)
			callable = callable.bind(i)
			callable = callable.bind(true)
			node.removed.connect(callable)


func update_state(id: int, state: bool):
	current_state[id] = state
	gate.close()
	if not current_state.has(false):
		gate.open()
