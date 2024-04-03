extends Node

@export var expected_state: Array[bool] = [true, false]
@onready var gate = $Gate

var lever_count = 2
var current_state: Array[bool] = expected_state # it'll change in _ready()

func _ready():
	for node in get_children():
		if is_instance_of(node, LeverTileEntity):
			current_state[node.id] = node.state

func update_state(id: int, state: bool):
	current_state[id] = state
	gate.close()
	if current_state == expected_state:
		gate.open()
