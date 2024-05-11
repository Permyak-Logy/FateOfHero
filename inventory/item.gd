class_name Item extends Resource

"""
Resource for item
It is just a struct for item. It cannot have quantity
you need to put it inside the ItemStack resource to make it tangeble
"""

@export var name: String
@export_multiline var description : String

@export var texture: Texture2D
@export var max_stack: int
@export var recipe: Array[Item]
@export var price: int


static func less(a: Item, b: Item):
	return a.name < b.name

