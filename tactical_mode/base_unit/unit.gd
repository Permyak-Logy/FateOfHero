extends CharacterBody2D

class_name Unit

@export var inventory: InventoryComponent
@export var health: StatComponent

signal walk_finished


func walk_along(way: Array):
	walk_finished.emit()
