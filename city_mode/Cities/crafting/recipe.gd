class_name Recipe extends Resource # TODO

@export var ingredients: Array[ItemStack] = []
@export var products: Array[ItemStack] = []
@export var is_known: bool = false

func check(inventory: Inventory) -> bool:
	"""Проверка на то, можно ли скрафтить из книги рецептов"""
	# inventory.get_item_stacks()
	return false

func check_from_ingredients(ing: Array[ItemStack]) -> bool:
	return false

func craft() -> Array[ItemStack]:
	return products.duplicate(true)

