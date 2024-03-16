extends Resource

class_name Item

@export var name: String
@export var texture: Texture2D
@export var max_stack: int

static func less(a: Item, b: Item):
	return a.name < b.name
	
