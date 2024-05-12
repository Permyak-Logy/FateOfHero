extends HBoxContainer

@onready var craft = $CraftResult
@export var item : Item = null
@onready var maxstack : int = item.max_stack
@onready var recipe = item.recipe
@onready var item_description : String = item.description
@onready var second_item_num: int = recipe.size() - 1
var des = true

var recipe_: Recipe # TODO

@onready var game: Game = get_tree().root.get_child(0)
@onready var global_inventory : Inventory = game.strat_map.player.inventory

func _ready():
	craft.icon = item.texture
 	
	get_child(0).item = recipe[0]
	get_child(2).item = recipe[1]
	
	if second_item_num > 1:
		$RecipeSlot2/NinePatchRect/Label.text = str(second_item_num)
 
func check():
	craft.disabled = true
	var inventory = $"../../../inventory/inventoryGrid"
	var flag = []
 	
	var f1 = inventory.how_much(recipe[0])
	var f2 = inventory.how_much(recipe[1])
	
	if f1 >= 1 and f2 >= second_item_num:
		craft.disabled = false

func _on_craft_result_pressed():
	var inventory = $"../../../inventory/inventoryGrid"
	for i in recipe:
		global_inventory.remove(i, 1)
	global_inventory.insert(item, 1)
	#craft.disabled = true
	inventory.update()
	check()

func _on_open_description_pressed():
	var description_window = $"../../../../description"
	description_window.add_description(item_description, des)
	des = !des