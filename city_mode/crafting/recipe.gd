extends HBoxContainer

@onready var craft = $CraftResult
@export var item : Item = null
@onready var maxstack : int = item.max_stack
@onready var recipe = item.recipe
@export var global_inventory : Inventory
@onready var item_description : String = item.descript
var des = true
 
func _ready():
	craft.icon = item.texture
 
	for i in range(recipe.size()):
		get_child(i).item = recipe[i]
 
func check():
	var flag = []
 
	for i in range(recipe.size()):
		flag.append(get_child(i).check())
 
	if false not in flag:
		craft.disabled = false

func _on_craft_result_pressed():
	var inventory = get_tree().current_scene.find_child("inventoryGrid")
 
	for i in recipe:
		inventory.remove_item(i, 1, maxstack)
		global_inventory.remove(i, 1)
	inventory.add_item(item, 1, maxstack)
	global_inventory.insert(item, 1)
	craft.disabled = true
	check()
	inventory.sort_items()


func _on_open_description_pressed():
	var description_window = get_tree().current_scene.find_child("description")
	description_window.add_description(item_description, des)
	des = !des
