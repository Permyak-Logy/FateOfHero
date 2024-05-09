extends VBoxContainer

func _on_inventory_grid_item_changed():
	for i in get_children():
		i.check()

func add_trade_item(item1, item2, item3):
	get_child(0).item = item1
	get_child(1).item = item2
	get_child(2).item = item3
