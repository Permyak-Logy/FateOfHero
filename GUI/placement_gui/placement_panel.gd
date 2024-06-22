class_name RunePlacementPanel extends Control

@onready var rune_slot: InventorySlot = $Back/Rune

var rune_type: int
var current_rune: ItemStackRepr = null

func update():
	rune_slot.item_stack_repr = current_rune
	rune_slot.update()
