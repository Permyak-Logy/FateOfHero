extends HBoxContainer

class_name trade

@onready var texture = $NinePatchRect/TextureRect
@onready var text = $Label
@onready var buy = $buy
@export var item : Item = null
@onready var maxstack : int = item.max_stack
@onready var price : int = item.price
@export var global_inventory : Inventory
@export var coin : Item
@onready var item_description : String = item.descript
var des = true

func _ready():
	texture.texture = item.texture
	text.text = str(item.price) + "G"
	$buy/Sprite2D.frame = 0

func check():
	var inventory = get_tree().current_scene.find_child("inventoryGrid")
	if inventory.how_much(coin) >= price:
		buy.disabled = false
		$buy/Sprite2D.frame = 1

func _on_buy_pressed():
	var inventory = get_tree().current_scene.find_child("inventoryGrid")
	inventory.remove_item(coin, price, 99)
	global_inventory.remove(coin, price)
	inventory.add_item(item, 1, maxstack)
	global_inventory.insert(item, 1)
	buy.disabled = true
	$buy/Sprite2D.frame = 0
	check()
	inventory.sort_items()


func _on_open_description_pressed():
	var description_window = get_tree().current_scene.find_child("description")
	description_window.add_description(item_description, des)
	des = !des
