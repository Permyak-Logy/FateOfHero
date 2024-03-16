extends Node

class_name InventoryComponent

@export var max_abilities = 3

var gears: Dictionary # Dict[Gear.Type, Gear]
var abilities: Array # List[Ability]

func use(gear) -> bool:
	return false

func unsuse(gear) -> bool:
	return false
