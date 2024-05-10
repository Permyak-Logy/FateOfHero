extends HBoxContainer

@onready var craft = $CraftResult
@export var item : Item = null
@onready var maxstack : int = item.max_stack
@onready var recipe = item.recipe
@export var global_inventory : Inventory
@onready var item_description : String = item.description
var des = true
 
func _ready():
	craft.icon = item.texture
 
	for i in range(recipe.size()):
		get_child(i).item = recipe[i]
 
func check():
	var inventory = $"../../../inventory/inventoryGrid"
	var flag = []
 
	for i in recipe:
		flag.append(inventory.is_available(i))
 
	if false not in flag:
		craft.disabled = false

func _on_craft_result_pressed():
	var inventory = $"../../../inventory/inventoryGrid"
	for i in recipe:
		global_inventory.remove(i, 1)
	global_inventory.insert(item, 1)
	craft.disabled = true
	inventory.update()
	check()


func _on_open_description_pressed():
	var description_window = $"../../../../description"
	description_window.add_description(item_description, des)
	des = !des
