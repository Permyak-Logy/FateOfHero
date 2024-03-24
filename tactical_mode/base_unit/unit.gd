extends CharacterBody2D

class_name Unit

@export var unit_name: String = "Unit"

@export var inventory: InventoryComponent = null
@export var health: StatComponent = null
@export var defence: StatComponent = null
@export var speed: StatComponent = null


@export var acts_count: int = 1
@export var cells_occupied: int = 1
@export var controlled_player: bool = true

signal walk_finished

var effects: Array[Effect] = []

func _ready():
	if health:
		health.empty.connect(death)

func apply_damage(damage: float, instigator: Unit = null):
	if not health:
		return 0
	if defence:
		damage = damage - defence.cur()
	damage = max(damage, 0)
	health.sub(damage)
	return damage

func walk_along(way: Array):
	walk_finished.emit()

func reload_all_mods():
	for node in get_children():
		if is_instance_of(node, StatComponent):
			# print(node)
			node.reload_mods()

func death():
	pass
