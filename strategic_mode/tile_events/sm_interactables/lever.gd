class_name LeverTileEntity extends AreaBasedInteractable

"""
lever changes it's state when action button is pressed and player is insede the area
"""

@export var id: int 
@export var state: bool = false

func _ready():
	pass

func change_state():
	state = not state
	sprite.frame = int(state)
	print("lever ", id, " pulled to ", state)
	get_parent().update_state(id, state)
	

func activate():
	change_state()

