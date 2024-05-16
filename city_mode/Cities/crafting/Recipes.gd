extends VBoxContainer


func _on_inventory_grid_item_changed():
	for recipe in get_children():
		recipe.check()
