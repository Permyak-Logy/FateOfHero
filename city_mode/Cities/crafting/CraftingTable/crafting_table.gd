extends NinePatchRect

@export var recipes: RecipeBook = null
@onready var av_recipes: Array[Recipe] = []
@export var global_inventory: Inventory = null

var is_known = false
var recipe : Recipe

@onready var CraftSlot1 = $CraftSlot
@onready var CraftSlot2 = $CraftSlot2

var res_item : Item = null:
	set(value):
		res_item = value
		
		if value != null and is_known:
			$Result/TextureRect.texture = res_item.texture
			$Result/Label.text = ""
		elif value != null:
			$Result/Label.text = "?"
		else:
			$Result/TextureRect.texture = null

func _ready():
	check()
	for i in recipes.Recipes:
		if i.is_known:
			av_recipes.append(i)

func check():
	$Result.disabled = true
	$Result/Back.frame = 0
	$Result/Label.text = ""
	var item1 = CraftSlot1.item
	var item2 = CraftSlot2.item
	var stack1 = CraftSlot1.stack
	var stack2 = CraftSlot2.stack
	if item1 != null and item2 != null:
		$Result.disabled = false
		$Result/Back.frame = 1
		$Result/Label.text = "?"
		for i in recipes.Recipes:
			if (item1 == i.ingredients_item[0] and item2 == i.ingredients_item[1]) or (item1 == i.ingredients_item[1] and item2 == i.ingredients_item[0]):
				is_known = i.is_known
				res_item = i.product
				recipe = i
				return
	res_item = null

func _on_result_pressed():
	CraftSlot1.stack -= 1
	if CraftSlot1.stack == 0:
		CraftSlot1.item = null
	CraftSlot2.stack -= 1
	if CraftSlot2.stack == 0:
		CraftSlot2.item = null
	if res_item != null:
		global_inventory.insert(res_item, 1)
		$"../../inventory/inventoryGrid".update()
		if !is_known:
			recipe.is_known = true
			$"../../Recipes/RecipeBook".update()
	check()

func remove_item(item):
	if CraftSlot1.item == item:
		CraftSlot1.remove_item()
	elif CraftSlot2.item == item:
		CraftSlot2.remove_item()
