class_name KeystoneTileEvent extends AreaBasedInteractable

@export var local_inventory: MicroInventory
# 1 = statisfied, 0 = not satisfied
signal state_changed(id: int, satisfied: bool)
var id: int # id for the scene master
var game: Game
var gui: RunePlacementGUI
var RunePlacementGUIRes: PackedScene = preload("res://GUI/placement_gui/concrete/keystone_placement_gui.tscn")


func _ready():
	game = get_tree().root.get_child(0)
	assert(id != null, "you forgot to assign id")
	if not local_inventory: local_inventory = MicroInventory.new()
	update()

func activate():
	gui = RunePlacementGUIRes.instantiate()
	gui.place_inventory = local_inventory
	gui.done.connect(on_gui_done)
	game.strat_map.gui.add_child(gui)
	game.strat_map.gui.open(gui)
	game.strat_map.pause()

func on_gui_done():
	game.strat_map.gui.remove_child(gui)
	game.strat_map.unpause()
	update()

func update():
	if local_inventory.contents:
		sprite.frame = 0
		state_changed.emit(id, true)
	else:
		sprite.frame = 1
		state_changed.emit(id, false)

func set_inventory(item_stack: MicroInventory):
	local_inventory = item_stack
	update()
	pass
