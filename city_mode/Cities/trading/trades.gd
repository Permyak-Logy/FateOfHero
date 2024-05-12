extends VBoxContainer

func _on_inventory_grid_item_changed():
	for i in get_children():
		i.check()

func add_trade_item(item, num):
	if $trade_item.item == null:
		$trade_item.item = item
		$trade_item.num = num
	elif $trade_item2.item == null:
		$trade_item2.item = item
		$trade_item2.num = num
	elif $trade_item3.item == null:
		$trade_item3.item = item
		$trade_item3.num = num

func clear():
	$trade_item.item = null
	$trade_item.num = 0
	$trade_item2.item = null
	$trade_item2.num = 0
	$trade_item3.item = null
	$trade_item3.num = 0
