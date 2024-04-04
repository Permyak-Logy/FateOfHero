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
@export var sprite_for_outline: Sprite2D = null

signal walk_finished
signal death

var effects: Array[Effect] = []

const PLAYER_COLOR = Vector4(0, 255, 0, 100)
const SELECTED_COLOR = Vector4(0, 0, 255, 100)
const ENEMY_COLOR = Vector4(255, 0, 0, 100)
const DEFAULT_COLOR = Vector4(0, 0, 0, 100)

func _ready():
	set_outline_color(DEFAULT_COLOR)

func set_outline_color(color: Vector4):
	if (sprite_for_outline == null):
		return
	(sprite_for_outline.material as ShaderMaterial).set_shader_parameter(
		"outline_color", color)
		
func apply_damage(damage: float, _instigator: Unit = null):
	if not health:
		return 0
	if defence:
		damage = damage - defence.cur()
	damage = max(damage, 0)
	health.sub(damage)
	return damage

func walk_along(_way: Array):
	walk_finished.emit()

func reload_all_mods():
	for node in get_children():
		if is_instance_of(node, StatComponent):
			node.reload_mods()

func get_mods() -> Dictionary:
	var all_mods = inventory.get_mods()
	return all_mods

func get_abilities() -> Array[Ability]:
	return []

func ai(map: TacticalMap):
	map.acts = 0
