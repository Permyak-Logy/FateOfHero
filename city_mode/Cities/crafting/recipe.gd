extends HBoxContainer

@onready var craft = $CraftResult
@export var item : Item = null
@onready var maxstack : int = item.max_stack
@onready var recipe = item.recipe
@onready var item_description : String = item.description
var des = true


@onready var game: Game = get_tree().root.get_child(0)
@onready var global_inventory : Inventory = game.strat_map.player.inventory

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
