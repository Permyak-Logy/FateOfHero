class_name Recipe extends Resource

@export var ingredients_item: Array[Item] = []
@export var ingredients_num: Array[int] = []
@export var product: Item = null
@export var is_known: bool = false

func check(inventory: Inventory) -> bool:
	"""Проверка на то, можно ли скрафтить из книги рецептов"""
	# inventory.get_item_stacks()
	return false
#
#func check_from_ingredients(ing: Array[ItemStack]) -> bool:
	#return false

#func craft() -> Array[ItemStack]:
	#return products.duplicate(true)

