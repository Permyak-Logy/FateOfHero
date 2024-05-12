extends HBoxContainer

class_name trade

@onready var maxstack : int = 0
@onready var price : int = 0
@onready var item_description : String = ""

var item : Item = null:
	set(value):
		item = value
		if value != null:
			$NinePatchRect/TextureRect.texture = value.texture
			maxstack = value.max_stack
			price = value.price
			if price > 999:
				$Label.text = str(price/1000) + "kG"
			else:
				$Label.text = str(price) + "G"
			item_description = value.description 
			visible = true
			check()
		else:
			$NinePatchRect/TextureRect.texture = null
			$Label.text = ""
			$buy/Sprite2D.frame = 0
			$buy.disabled = true
			visible = false

var num : int = 0:
	set(value):
		num = value
		
		if value > 1:
			$NinePatchRect/TextureRect/Label.text = str(num)
		else:
			$NinePatchRect/TextureRect/Label.text = ""

#@onready var game: Game = get_tree().root.get_child(0)
#@onready var global_inventory : Inventory = game.strat_map.player.inventory
@export var global_inventory: Inventory

@export var coin : Item
var des = true

func check():
	$buy.disabled = true
	$buy/Sprite2D.frame = 0
	var inventory = $"../../../inventory/inventoryGrid1"
	if inventory.how_much(coin) >= price:
		print("checked")
		$buy.disabled = false
		$buy/Sprite2D.frame = 1

func _on_buy_pressed():
	var inventory = $"../../../inventory/inventoryGrid1"
	global_inventory.remove(coin, price)
	global_inventory.insert(item, 1)
	inventory.update()
	$"../../../../".remove_item(item, 1)
	$"../../../../".update()
	$"../../../../".place()


func _on_open_description_pressed():
	var description_window = $"../../../../description"
	description_window.add_description(item_description, des)
	des = !des
