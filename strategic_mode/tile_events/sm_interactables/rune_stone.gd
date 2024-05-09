class_name RuneTileEvent extends AreaBasedInteractable

@onready var game: Game = get_tree().root.get_child(0)
@onready var rune_sprite: Sprite2D = $Rune


@export var type: int 
# is_satisfied
var state: bool = false
var gui: RunePlacementGUI
var RunePlacementGUIRes: PackedScene = preload("res://GUI/rune_placement/rune_placement_gui.tscn")
var inventory = MicroInventory.new()

func _ready():
	assert(type != 0, "you forgot to assign type")
	var stone_texture: Texture2D = load("res://strategic_mode/tile_events/sprites/stone" + str(type) + ".png")
	sprite.texture = stone_texture

func activate():
	gui = RunePlacementGUIRes.instantiate()
	gui.place_inventory = inventory
	gui.done.connect(on_gui_done)
	game.strat_map.gui.add_child(gui)
	game.strat_map.gui.busy = true
	game.strat_map.pause()

func on_gui_done():
	print(inventory.contents)
	game.strat_map.gui.remove_child(gui)
	game.strat_map.gui.busy = false
	rune_sprite.texture
	game.strat_map.unpause()
