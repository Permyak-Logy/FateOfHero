extends HBoxContainer

const trade_cf: float = 1.2

@export var coin : Item

@onready var InventoryGrid = $"../../../inventory/inventoryGrid1"
@onready var TradeGrid = $"../../../TradeInventory/TradeGrid"
@onready var sale =  $"../sale"
@onready var buy = $"../buy"

var price : float

func check():
	price = sale.get_price() - buy.get_price()*trade_cf
	if price > 0:
		$Label.text = "+" + str(int(price)) + "G"
	elif price == 0:
		$Label.text = "0G"
	else:
		$Label.text = str(int(price)) + "G"
	
	var slots_player : int = 0
	for i in buy.get_children():
		if i.item != null:
			slots_player += InventoryGrid.check_item(i.item, i.stack)
	var cond1 = slots_player <= InventoryGrid.free_slots() and InventoryGrid.free_slots() != 0
	
	var slots_traider : int = 0
	for i in sale.get_children():
		if i.item != null:
			slots_traider += TradeGrid.check_item(i.item, i.stack)
	var cond2 = slots_traider <= TradeGrid.free_slots() and TradeGrid.free_slots() != 0
	
	if (price < 0 and InventoryGrid.how_much(coin) > price*(-1)) or (price > 0 and TradeGrid.how_much(coin) > price) or price == 0:
		if cond1 and cond2:
			$Buttonbuy.disabled = false
			$Buttonbuy/back.frame = 1
			return true
	$Buttonbuy.disabled = true
	$Buttonbuy/back.frame = 0
	return false

func _ready():
	check()


func _on_buttonbuy_pressed():
	for i in sale.get_children():
		if i.item != null:
			$"../../../..".trading_inventory.insert(i.item, i.stack)
	for i in buy.get_children():
		if i.item != null:
			InventoryGrid.inventory.insert(i.item, i.stack)
	if price > 0:
		$"../../../..".trading_inventory.remove(coin, int(price))
		InventoryGrid.inventory.insert(coin, int(price))
	elif price < 0:
		$"../../../..".trading_inventory.insert(coin, int(price)*(-1))
		InventoryGrid.inventory.remove(coin, int(price)*(-1))
	TradeGrid.update()
	InventoryGrid.update()
	sale.clear()
	buy.clear()
	check()


func _on_reset_button_pressed():
	for i in sale.get_children():
		if i.item != null:
			InventoryGrid.inventory.insert(i.item, i.stack)
	sale.clear()
	for i in buy.get_children():
		if i.item != null:
			$"../../../..".trading_inventory.insert(i.item, i.stack)
	InventoryGrid.update()
	TradeGrid.update()
	buy.clear()
	check()
