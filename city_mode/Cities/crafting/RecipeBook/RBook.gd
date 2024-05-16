extends VBoxContainer

@onready var game: Game = get_tree().root.get_child(0)
@onready var inventory : Inventory = game.strat_map.player.inventory
@export var recipes : RecipeBook = null
@onready var av_recipes : Array[Recipe] = []

@onready var page1 = $Recipes/Page1
@onready var page2 = $Recipes/Page2
@onready var page3 = $Recipes/Page3
@onready var page4 = $Recipes/Page4

func _ready():
	update()

func update():
	av_recipes = []
	page1.remove_recipe()
	page2.remove_recipe()
	page3.remove_recipe()
	page4.remove_recipe()
	for i in range(recipes.Recipes.size()):
		if inventory.recipes_known[i]:
			av_recipes.append(recipes.Recipes[i])
	print(av_recipes)
	if av_recipes.size() == 0:
		page1.visible = false
		$Recipes/Label.visible = true
	if av_recipes.size() > 0:
		page1.visible = true
		$Recipes/Label.visible = false
		if av_recipes.size() <= 3:
			for i in range(av_recipes.size()):
				page1.add_recipe(av_recipes[i])
		else:
			for i in range(3):
				page1.add_recipe(av_recipes[i])
	if av_recipes.size() > 3:
		$PageButtons/PB1.visible = true
		$PageButtons/PB2.visible = true
		if  av_recipes.size() <= 6:
			for i in range(3, av_recipes.size()):
				page2.add_recipe(av_recipes[i])
		else:
			for i in range(3, 6):
				page2.add_recipe(av_recipes[i])
	if av_recipes.size() > 6:
		$PageButtons/PB3.visible = true
		if  av_recipes.size() <= 9:
			for i in range(6, av_recipes.size()):
				page3.add_recipe(av_recipes[i])
		else:
			for i in range(6, 9):
				page3.add_recipe(av_recipes[i])
	if av_recipes.size() > 9:
		$PageButtons/PB4.visible = true
		if  av_recipes.size() <= 12:
			for i in range(9, av_recipes.size()):
				page4.add_recipe(av_recipes[i])
		else:
			for i in range(9, 12):
				page4.add_recipe(av_recipes[i])

@onready var pb1_back = $PageButtons/PB1/Back
@onready var pb2_back = $PageButtons/PB2/Back
@onready var pb3_back = $PageButtons/PB3/Back
@onready var pb4_back = $PageButtons/PB4/Back

func _on_pb_1_pressed():
	page1.visible = true
	page2.visible = false
	page3.visible = false
	page4.visible = false
	pb1_back.frame = 1
	pb2_back.frame = 0
	pb3_back.frame = 0
	pb4_back.frame = 0

func _on_pb_2_pressed():
	page1.visible = false
	page2.visible = true
	page3.visible = false
	page4.visible = false
	pb1_back.frame = 0
	pb2_back.frame = 1
	pb3_back.frame = 0
	pb4_back.frame = 0

func _on_pb_3_pressed():
	page1.visible = false
	page2.visible = false
	page3.visible = true
	page4.visible = false
	pb1_back.frame = 0
	pb2_back.frame = 0
	pb3_back.frame = 1
	pb4_back.frame = 0

func _on_pb_4_pressed():
	page1.visible = false
	page2.visible = false
	page3.visible = false
	page4.visible = true
	pb1_back.frame = 0
	pb2_back.frame = 0
	pb3_back.frame = 0
	pb4_back.frame = 1
