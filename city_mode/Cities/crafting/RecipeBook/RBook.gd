extends VBoxContainer

@export var recipes : RecipeBook = null
@onready var av_recipes : Array[Recipe] = []

func _ready():
	update()

func update():
	av_recipes = []
	$Recipes/Page1.remove_recipe()
	$Recipes/Page2.remove_recipe()
	$Recipes/Page3.remove_recipe()
	$Recipes/Page4.remove_recipe()
	for i in range(recipes.Recipes.size()):
		if recipes.Recipes[i].is_known:
			av_recipes.append(recipes.Recipes[i])
	print(av_recipes)
	print(av_recipes.size())
	if av_recipes.size() == 0:
		$Recipes/Page1.visible = false
		$Recipes/Label.visible = true
	if av_recipes.size() > 0:
		if av_recipes.size() <= 3:
			for i in range(av_recipes.size()):
				$Recipes/Page1.add_recipe(av_recipes[i])
		else:
			for i in range(3):
				$Recipes/Page1.add_recipe(av_recipes[i])
	if av_recipes.size() > 3:
		$PageButtons/PB1.visible = true
		$PageButtons/PB2.visible = true
		if  av_recipes.size() <= 6:
			for i in range(3, av_recipes.size()):
				$Recipes/Page2.add_recipe(av_recipes[i])
		else:
			for i in range(3, 6):
				$Recipes/Page2.add_recipe(av_recipes[i])
	if av_recipes.size() > 6:
		$PageButtons/PB3.visible = true
		if  av_recipes.size() <= 9:
			for i in range(6, av_recipes.size()):
				$Recipes/Page3.add_recipe(av_recipes[i])
		else:
			for i in range(6, 9):
				$Recipes/Page3.add_recipe(av_recipes[i])
	if av_recipes.size() > 9:
		$PageButtons/PB4.visible = true
		if  av_recipes.size() <= 12:
			for i in range(9, av_recipes.size()):
				$Recipes/Page4.add_recipe(av_recipes[i])
		else:
			for i in range(9, 12):
				$Recipes/Page4.add_recipe(av_recipes[i])

func _on_pb_1_pressed():
	$Recipes/Page1.visible = true
	$Recipes/Page2.visible = false
	$Recipes/Page3.visible = false
	$Recipes/Page4.visible = false
	$PageButtons/PB1/Back.frame = 1
	$PageButtons/PB2/Back.frame = 0
	$PageButtons/PB3/Back.frame = 0
	$PageButtons/PB4/Back.frame = 0

func _on_pb_2_pressed():
	$Recipes/Page1.visible = false
	$Recipes/Page2.visible = true
	$Recipes/Page3.visible = false
	$Recipes/Page4.visible = false
	$PageButtons/PB1/Back.frame = 0
	$PageButtons/PB2/Back.frame = 1
	$PageButtons/PB3/Back.frame = 0
	$PageButtons/PB4/Back.frame = 0

func _on_pb_3_pressed():
	$Recipes/Page1.visible = false
	$Recipes/Page2.visible = false
	$Recipes/Page3.visible = true
	$Recipes/Page4.visible = false
	$PageButtons/PB1/Back.frame = 0
	$PageButtons/PB2/Back.frame = 0
	$PageButtons/PB3/Back.frame = 1
	$PageButtons/PB4/Back.frame = 0

func _on_pb_4_pressed():
	$Recipes/Page1.visible = false
	$Recipes/Page2.visible = false
	$Recipes/Page3.visible = false
	$Recipes/Page4.visible = true
	$PageButtons/PB1/Back.frame = 0
	$PageButtons/PB2/Back.frame = 0
	$PageButtons/PB3/Back.frame = 0
	$PageButtons/PB4/Back.frame = 1
