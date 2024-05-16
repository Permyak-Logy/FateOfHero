extends NinePatchRect

@export var recipes: RecipeBook = null
@onready var av_recipes: Array[Recipe] = []
@onready var game: Game = get_tree().root.get_child(0)
@onready var global_inventory : Inventory = game.strat_map.player.inventory

var is_known = false
var recipe : Recipe
@onready var recipe_idx: int = 0

@onready var craft_slot1 = $CraftSlot
@onready var craft_slot2 = $CraftSlot2
@onready var label = $Result/Label
@onready var texture_rect = $Result/TextureRect
@onready var inventory_grid = $"../../inventory/inventoryGrid"
@onready var res_button = $Result
@onready var res_back = $Result/Back

@onready var item1
@onready var item2 
@onready var stack1
@onready var stack2

var res_item : Item = null:
	set(value):
		res_item = value
		
		if value != null and global_inventory.recipes_known[recipe_idx]:
			texture_rect.texture = res_item.texture
			label.text = ""
		elif value != null:
			label.text = "?"
		else:
			texture_rect.texture = null

func _ready():
	check()
	for i in range(recipes.Recipes.size()):
		if global_inventory.recipes_known[i]:
			av_recipes.append(recipes.Recipes[i])

func check():
	res_button.disabled = true
	res_back.frame = 0
	label.text = ""
	item1 = craft_slot1.item
	item2 = craft_slot2.item
	stack1 = craft_slot1.stack
	stack2 = craft_slot2.stack
	if item1 != null and item2 != null and inventory_grid.free_slots() >= 1 and inventory_grid.free_slots() != 0:
		res_button.disabled = false
		res_back.frame = 1
		label.text = "?"
		var count = 0
		for i in recipes.Recipes:
			var cond1 = (item1 == i.ingredients_item[0] and item2 == i.ingredients_item[1]) or (item1 == i.ingredients_item[1] and item2 == i.ingredients_item[0])
			var cond2 = (stack1 >= i.ingredients_num[0] and stack2 >= i.ingredients_num[1]) or (stack1 >= i.ingredients_num[1] and stack2 >= i.ingredients_num[0])
			if cond1 and cond2:
				res_item = i.product
				recipe = i
				recipe_idx = count
				is_known = global_inventory.recipes_known[recipe_idx]
				return
			count += 1
	res_item = null

func _on_result_pressed():
	if res_item != null:
		craft_slot1.stack -= recipe.ingredients_num[0]
		craft_slot2.stack -= recipe.ingredients_num[1]
		global_inventory.insert(res_item, 1)
		inventory_grid.update()
		if !is_known:
			#recipe.is_known = true
			global_inventory.open_recipe(recipe_idx)
			$"../../Recipes/RecipeBook".update()
	else:
		craft_slot1.stack -= 1
		craft_slot2.stack -= 1
	if craft_slot1.stack == 0:
		craft_slot1.item = null
	if craft_slot2.stack == 0:
		craft_slot2.item = null
	check()

func remove_item(item):
	if craft_slot1.item == item:
		craft_slot1.remove_item()
	elif craft_slot2.item == item:
		craft_slot2.remove_item()

func clear_slots():
	$CraftSlot.clear()
	$CraftSlot2.clear()
	$"../../inventory/inventoryGrid".update()
