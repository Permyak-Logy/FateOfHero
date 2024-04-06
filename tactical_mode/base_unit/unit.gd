class_name Unit extends Node2D

@export var unit_name: String = "Unit"

@export_group("Components")
@export var inventory: InventoryComponent = null
@export var health: StatComponent = null
@export var defence: StatComponent = null
@export var speed: StatComponent = null
@export var damage: StatComponent = null
@export var sprite_for_outline: Sprite2D = null

@export_group("Unit stats")
@export var acts_count: int = 1
@export var cells_occupied: int = 1
@export var controlled_player: bool = true
@export var max_attack_distance = 1

signal death(Unit)

var _effects: Array[Effect] = []

const PLAYER_COLOR = Vector4(0, 255, 0, 100)
const CUR_COLOR = Vector4(255, 255, 255, 100)
const SELECTED_COLOR = Vector4(0, 0, 255, 100)
const ENEMY_COLOR = Vector4(255, 0, 0, 100)
const DEFAULT_COLOR = Vector4(0, 0, 0, 100)

var outline_shader = preload("res://tactical_mode/base_unit/outline_shader.tres")
@onready var attack_ability = AttackAbility.new(max_attack_distance)

func _ready():
	if sprite_for_outline:
		(sprite_for_outline as CanvasItem).material = outline_shader.duplicate()
	if health:
		health.empty.connect(on_death)
	set_outline_color(DEFAULT_COLOR)

func set_outline_color(color: Vector4):
	if (sprite_for_outline == null):
		return
	(sprite_for_outline.material as ShaderMaterial).set_shader_parameter(
		"outline_color", color)
		
func apply_damage(damage: float, _instigator: Unit = null):
	for effect in _instigator.get_effects():
		damage = effect.update_on_attack(damage, self)
	
	if not health:
		return 0
	
	if defence:
		damage = damage - defence.cur()
	
	for effect in get_effects():
		damage = effect.update_on_damage(damage, _instigator)
	
	damage = max(damage, 0)
	health.sub(damage)
	
	return damage

func reload_all_mods():
	for node in get_children():
		if is_instance_of(node, StatComponent):
			node.reload_mods()

func get_mods() -> Dictionary:
	var all_mods = inventory.get_mods()
	return all_mods

func get_abilities() -> Array[Ability]:
	return [attack_ability]

func ai(map: TacticalMap):
	map.acts = 0

func get_cell() -> Vector2i:
	return get_map().to_map(global_position)

func get_map() -> TacticalMap:
	return get_parent() as TacticalMap

func init_fight():
	reload_all_mods()
	for ability in get_abilities():
		ability.set_owner(self)
		ability.reset()

func premove_update():
	for ability in get_abilities():
		ability.update()
	for effect in get_effects():
		effect.update_on_move()

func play(name: String, args=null):
	return

func on_death(component: StatComponent):
	set_outline_color(Vector4(10, 0, 0, 100))
	play("death")
	death.emit(self)

func is_death() -> bool:
	return not health or health.cur() <= 0

func _on_toggle_select(viewport, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("select"):
		var ability = get_map().cur_ability
		if not ability:
			return
		if not ability.can_select(self):
			return
		if self in ability.selected:
			ability.unselect(self)
		else:
			ability.select(self)

func get_effects() -> Array[Effect]:
	return _effects

func add_effect(effect: Effect):
	_effects.append(effect)
	effect.set_owner(self)
	effect.finished.connect(remove_effect)
	effect.updated_mods.connect(reload_all_mods)

func remove_effect(effect: Effect):
	_effects.erase(effect)
	effect.finished.disconnect(remove_effect)
	effect.updated_mods.disconnect(reload_all_mods)
