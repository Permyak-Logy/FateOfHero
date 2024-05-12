extends HBoxContainer

@onready var des = true

var recipe : Recipe = null:
	set(value):
		recipe = value
		
		if value != null:
			$RecipeSlot.item = recipe.ingredients_item[0]
			$RecipeSlot.num = recipe.ingredients_num[0]
			$RecipeSlot2.item = recipe.ingredients_item[1]
			$RecipeSlot2.num = recipe.ingredients_num[1]
			$RecipeSlot3.item = recipe.product
			visible = true
		else:
			visible = false

func _on_button_pressed():
	$"../../../../../../description".add_description(recipe.product.description, des)
	des = !des
