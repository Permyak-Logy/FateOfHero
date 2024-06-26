class_name CraftVillage extends City

@onready var game: Game = get_tree().root.get_child(0)
@onready var crafting = $crafting
@onready var exit_button_texture =  $exit/button_texture

func _ready():
	var inventory = $crafting/HBoxContainer/inventory/inventoryGrid
	exit_button_texture.frame = 1
	inventory.update()

func _on_exit_pressed():
	crafting.clear()
	game.to_strat_mode()
