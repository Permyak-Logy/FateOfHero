extends HBoxContainer

const trade_cf: float = 1.2

@export var coin : Item

@onready var InventoryGrid = $"../../../inventory/inventoryGrid1"
@onready var TradeGrid = $"../../../TradeInventory/TradeGrid"
@onready var Sale =  $"../sale"
@onready var Buy = $"../buy"

var price : float

func check():
	price = Sale.get_price() - Buy.get_price()*trade_cf
	if price > 0:
		$Label.text = "+" + str(int(price)) + "G"
	elif price == 0:
		$Label.text = "0G"
	else:
		$Label.text = str(int(price)) + "G"
	
	var slots_player : int = 0
	for i in Buy.get_children():
		if i.item != null:
			slots_player += InventoryGrid.check_item(i.item, i.stack)
	var cond1 = InventoryGrid.get_children().size() >= slots_player + InventoryGrid.free_slots()
	
	var slots_traider : int = 0
	for i in Sale.get_children():
		if i.item != null:
			slots_traider += TradeGrid.check_item(i.item, i.stack)
	var cond2 = TradeGrid.get_children().size() >= slots_player + TradeGrid.free_slots()
	
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
	for i in Sale.get_children():
		if i.item != null:
			$"../../../..".TradingInventory.insert(i.item, i.stack)
	for i in Buy.get_children():
		if i.item != null:
			InventoryGrid.inventory.insert(i.item, i.stack)
	if price > 0:
		$"../../../..".TradingInventory.remove(coin, int(price))
		InventoryGrid.inventory.insert(coin, int(price))
	elif price < 0:
		$"../../../..".TradingInventory.insert(coin, int(price)*(-1))
		InventoryGrid.inventory.remove(coin, int(price)*(-1))
	TradeGrid.update()
	InventoryGrid.update()
	Sale.clear()
	Buy.clear()
	check()


func _on_reset_button_pressed():
	for i in Sale.get_children():
		if i.item != null:
			InventoryGrid.inventory.insert(i.item, i.stack)
	Sale.clear()
	for i in Buy.get_children():
		if i.item != null:
			$"../../../..".TradingInventory.insert(i.item, i.stack)
	InventoryGrid.update()
	TradeGrid.update()
	Buy.clear()
	check()
