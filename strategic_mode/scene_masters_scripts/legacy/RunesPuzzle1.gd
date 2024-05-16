extends Node

"""
Thing that opens mus be named <Prize>
"""

@onready var prize = $Prize

@export var current_state: Array[bool] = []

func _ready():
	var i = 0
	for node in get_children():
		if is_instance_of(node, RuneTileEvent):
			node.id = i
			current_state.append(false)
			node.state_changed.connect(update_state)
			i += 1
	

func update_state(id: int, state: bool):
	current_state[id] = state
	prize.close()
	if not current_state.has(false):
		prize.open()
