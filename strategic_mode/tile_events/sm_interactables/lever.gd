class_name LeverTileEntity extends AreaBasedInteractable

"""
lever changes it's state when action button is pressed and player is insede the area
"""
# 1 = statisfied, 0 = not satisfied
signal state_changed(id: bool, state: bool)

@export var id: int 
@export var state: bool = false
@export var expected_state: bool = true

func _ready():
	pass

func change_state():
	state = not state
	sprite.frame = int(state)
	print("lever ", id, " pulled to ", state)
	state_changed.emit(id, state == expected_state)	

func activate():
	change_state()

