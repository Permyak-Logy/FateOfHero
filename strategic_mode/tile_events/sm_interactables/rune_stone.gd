class_name RuneTileEvent extends AreaBasedInteractable

var game: Game
@onready var rune_sprite: Sprite2D = $Rune

signal stone_changed(id: int, satisfied: bool)

@export var type: int 
var id: int

var rune_inside: int
var gui: RunePlacementGUI
var RunePlacementGUIRes: PackedScene = preload("res://GUI/rune_placement/rune_placement_gui.tscn")
var local_inventory = MicroInventory.new()
var rune_sprites: Array[Texture2D] = [
	null,
	preload("res://strategic_mode/tile_events/sprites/rune1.png"),
	preload("res://strategic_mode/tile_events/sprites/rune2.png"),
	preload("res://strategic_mode/tile_events/sprites/rune3.png"),
	preload("res://strategic_mode/tile_events/sprites/rune4.png"),
	preload("res://strategic_mode/tile_events/sprites/rune5.png"),
	preload("res://strategic_mode/tile_events/sprites/rune6.png"),
	preload("res://strategic_mode/tile_events/sprites/rune7.png"),
	preload("res://strategic_mode/tile_events/sprites/rune8.png")	
]

func _ready():
	game = get_tree().root.get_child(0)
	assert(type != 0, "you forgot to assign type")
	assert(id != null, "you forgot to assign id")
	var stone_texture: Texture2D = load("res://strategic_mode/tile_events/sprites/stone" + str(type) + ".png")
	sprite.texture = stone_texture

func activate():
	gui = RunePlacementGUIRes.instantiate()
	gui.place_inventory = local_inventory
	gui.done.connect(on_gui_done)
	game.strat_map.gui.add_child(gui)
	game.strat_map.gui.busy = true
	game.strat_map.pause()

func on_gui_done():
	print(local_inventory.contents)
	game.strat_map.gui.remove_child(gui)
	game.strat_map.gui.busy = false
	rune_sprite.texture
	game.strat_map.unpause()
	if local_inventory.contents:
		rune_inside = int(local_inventory.contents.item.name.get_slice("_", 1))
	else:
		rune_inside = 0
	rune_sprite.texture = rune_sprites[rune_inside]
	stone_changed.emit(id, type == rune_inside)
	update()

func update():
	if type == rune_inside:
		rune_sprite.frame = 1
	else:
		rune_sprite.frame = 0
