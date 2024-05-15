extends PanelContainer

var item_price = 0
@export var coin : Item

var item : Item = null:
	set(value):
		item = value
		
		if value != null:
			$TextureRect.texture = item.texture
			$Back.frame = 1
			price = item.price
			item_price = item.price
		else:
			$TextureRect.texture = null
			$Back.frame = 0
			price = 0

var price : int = 0:
	set(value):
		price = value
		
		$"../Price".text = str(price) + "G"

var stack : int = 0:
	set(value):
		stack = value
		
		if value > 1:
			$Label.text = str(stack)
		else:
			$Label.text = ""

func _can_drop_data(_pos, data):
	return true
 
func check():
	$"../Sale".disabled = true
	$"../Sale/Back".frame = 0
	if $"../../../inventory/inventoryGrid1".how_much(item) >= stack and $"../../../..".check_place():
		$"../Sale".disabled = false
		$"../Sale/Back".frame = 1

func _drop_data(_at_position, data):
	if data.item == item:
		stack += 1
		price += item_price
	else:
		item = data.item
		stack = 1
	check()

func _on_reset_pressed():
	item = null
	stack = 0

@onready var game: Game = get_tree().root.get_child(0)
@onready var global_inventory : Inventory = game.strat_map.player.inventory
#@export var global_inventory : Inventory

func _on_sale_pressed():
	global_inventory.insert(coin, price)
	global_inventory.remove(item, stack)
	$"../../../..".add_item(item, stack)
	$"../../../..".update()
	$"../../../inventory/inventoryGrid1".update()
	$"../../../..".place()
	item = null
	stack = 0
