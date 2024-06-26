class_name TradingVillage extends City

@onready var game: Game = get_tree().root.get_child(0)
@onready var trading = $Trading
@onready var exit_button_texture =  $exit/button_texture

func _ready():
	var inventory = $Trading/HBoxContainer/inventory/inventoryGrid1
	exit_button_texture.frame = 1
	inventory.update()

func _on_exit_pressed():
	trading.clear()
	game.to_strat_mode()
