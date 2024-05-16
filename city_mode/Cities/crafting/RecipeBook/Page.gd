extends VBoxContainer

func add_recipe(recipe):
	if $Recipe.recipe == null:
		$Recipe.recipe = recipe
	elif $Recipe2.recipe == null:
		$Recipe2.recipe = recipe
	elif $Recipe3.recipe == null:
		$Recipe3.recipe = recipe

func remove_recipe():
	$Recipe.recipe = null
	$Recipe2.recipe = null
	$Recipe3.recipe = null

func hide():
	for i in get_children():
		if i.recipe == null:
			i.visible = false
		else:
			i.visible = true
