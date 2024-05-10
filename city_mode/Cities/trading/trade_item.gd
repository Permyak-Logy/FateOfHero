extends HBoxContainer

class_name trade

@onready var maxstack : int = 0
@onready var price : int = 0
@onready var item_description : String = ""

@export var item : Item = null:
	set(value):
		item = value
		if value != null:
			$NinePatchRect/TextureRect.texture = value.texture
			$Label.text = str(item.price) + "G"
			maxstack = value.max_stack
			price = value.price
			item_description = value.description
			$buy/Sprite2D.frame = 1
			$buy.disabled = false
		else:
			$NinePatchRect/TextureRect.texture = null
			$Label.text = ""
			$buy/Sprite2D.frame = 0
			$buy.disabled = true

@onready var game: Game = get_tree().root.get_child(0)
@onready var global_inventory : Inventory = game.strat_map.player.inventory

@export var coin : Item
var des = true

func check():
	var inventory = $"../../../inventory/inventoryGrid1"
	if inventory.how_much(coin) >= price and price != 0:
		$buy.disabled = false
		$buy/Sprite2D.frame = 1

func _on_buy_pressed():
	var inventory = $"../../../inventory/inventoryGrid1"
	global_inventory.remove(coin, price)
	global_inventory.insert(item, 1)
	$buy.disabled = true
	$buy/Sprite2D.frame = 0
	inventory.update()
	check()


func _on_open_description_pressed():
	var description_window = $"../../../../description"
	description_window.add_description(item_description, des)
	des = !des
