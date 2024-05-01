class_name Unit extends Actor

@export var unit_name: String = "Unit"

@export_group("Components")
@export var inventory: InventoryComponent = null
@export var health: StatComponent = null
@export var defence: StatComponent = null
@export var speed: StatComponent = null
@export var damage: StatComponent = null
@export var expirience: ExpirienceComponent = null
@export var sprite_for_outline: Sprite2D = null
@export var trail_particles: GPUParticles2D = null
@export var health_bar_pb: StatProgressBar = null

@export_group("Unit stats")
@export var acts_count: int = 1
@export var controlled_player: bool = true

@export_group("Unit abilities")
@export var private_abilities: Array[Ability] = []
@export var private_passives: Array[Effect] = []

var _abilities: Array[Ability] = []
signal death(Unit)
signal walk_finished

var current_id_path: Array = []

var _effects: Array[Effect] = []
var flipped: bool = false
var timer_for_walk_trail: SceneTreeTimer = null

const PLAYER_COLOR = Vector4(0, 255, 0, 100)
const CUR_COLOR = Vector4(255, 255, 255, 100)
const SELECTED_COLOR = Vector4(0, 0, 255, 100)
const ENEMY_COLOR = Vector4(255, 0, 0, 100)
const DEFAULT_COLOR = Vector4(0, 0, 0, 100)
const ESCAPE_COLOR = Vector4(255, 255, 0, 100)

var outline_shader = preload("res://tactical_mode/assets/outline_shader.tres")

func _ready():
	_setcopy_resources()
	if sprite_for_outline:
		(sprite_for_outline as CanvasItem).material = outline_shader.duplicate()
	if health:
		health.empty.connect(on_death)
		if health_bar_pb:
			health_bar_pb.stat_component = health
	for ability in private_abilities:
		_abilities.append(ability.duplicate(true))
	if trail_particles:
		trail_particles.hide()
	set_outline_color(DEFAULT_COLOR)

func _setcopy_resources():
	if inventory:
		inventory = inventory.duplicate(true)
	if health:
		health = health.duplicate(true)
	if defence:
		defence = defence.duplicate(true)
	if speed:
		speed = speed.duplicate(true)
	if damage:
		damage = damage.duplicate(true)
	if expirience:
		expirience = expirience.duplicate(true)

func set_outline_color(color: Vector4):
	if (sprite_for_outline == null):
		return
	(sprite_for_outline.material as ShaderMaterial).set_shader_parameter(
		"outline_color", color)
		
func apply_damage(_damage: float, _instigator: Unit = null):
	if _instigator:
		for effect in _instigator.get_effects():
			_damage = effect.update_on_attack(_damage, self)
	
	if not health:
		return 0
	
	if defence:
		_damage = _damage - defence.cur()
	
	for effect in get_effects():
		_damage = effect.update_on_damage(_damage, _instigator)
	
	_damage = max(_damage, 0)
	health.sub(_damage)
	
	return _damage

func reload_all_mods():
	for node in get_children():
		if is_instance_of(node, StatComponent):
			node.reload_mods(self)

func get_mods() -> Dictionary:
	var all_mods: Dictionary = inventory.get_mods()
	for effect in _effects:
		for mod in effect.get_mods():
			if mod.type in all_mods:
				all_mods[(mod as Mod).type].iadd((mod as Mod).value)
			else:
				all_mods[(mod as Mod).type] = (mod as Mod).value
	return all_mods

func get_abilities() -> Array[Ability]:
	if inventory:
		return _abilities + inventory.get_abilities()
	return _abilities

func apply_passives():
	for effect in private_passives:
		var passive: Effect = effect.duplicate(true)
		passive.instigator = self
		add_effect(passive)

func ai(map: TacticalMap):
	map.acts = 0

func get_occupied_cells() -> Array[Vector2i]:
	return [get_cell()]

func prepare_fight():
	print("=> Prepare: ", unit_name)
	while _effects:
		remove_effect(_effects[0])
	
	reload_all_mods()
	for ability in get_abilities():
		ability.set_owner(self)
		ability.reset()
	apply_passives()
	flip_unit(idle_direction_bool())

func premove_update():
	for ability in get_abilities():
		ability.update()
	for effect in get_effects():
		effect.update_on_move()

func flip_unit(toggle: bool):
	if toggle == flipped:
		return
	flipped = toggle
	if trail_particles:
		var i: Image = trail_particles.texture.get_image()
		i.flip_x()
		trail_particles.texture = ImageTexture.create_from_image(i)
	sprite_for_outline.flip_h = flipped
	

func _physics_process(_delta):
	if current_id_path.is_empty():
		play("idle")
		return

	var target_position = $"../TileMap".map_to_local(current_id_path.front())
	play("run")
	

	if (target_position - global_position)[0] == 0:
		flip_unit(idle_direction_bool())
	else:
		flip_unit((target_position - global_position)[0] < 0)

	global_position = global_position.move_toward(target_position, 3)
	
	if global_position == target_position:    
		current_id_path.pop_front()
		if not current_id_path:
			flip_unit(idle_direction_bool())
			walk_finished.emit()

func idle_direction_bool():
	return get_map().is_enemy(self)
	
func play(_name: String, _params=null):
	if _name == "walk":
		if trail_particles:
			if timer_for_walk_trail:
				timer_for_walk_trail.timeout.disconnect(trail_particles.hide)
			trail_particles.show()
		current_id_path = _params
		
		await walk_finished
		
		if trail_particles:
			timer_for_walk_trail = get_tree().create_timer(trail_particles.lifetime)
			timer_for_walk_trail.timeout.connect(trail_particles.hide)

func on_death(_component: StatComponent):
	print("Death ", self)
	play("death")
	death.emit(self)

func is_death() -> bool:
	if not health:
		return false
	return health.cur() <= 0

func _on_toggle_select(_viewport, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("select"):
		var ability = get_map().cur_ability
		if not ability or not is_instance_of(ability, DirectedAbility):
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
	print("=> ", self.unit_name, " получил эффект ", effect.effect_name)
	_effects.append(effect)
	effect.owner = self
	effect.finished.connect(remove_effect)
	effect.updated_mods.connect(reload_all_mods)
	reload_all_mods()

func remove_effect(effect: Effect):
	print("=> ", self.unit_name, " кончился эффект ", effect.effect_name)
	_effects.erase(effect)
	effect.finished.disconnect(remove_effect)
	effect.updated_mods.disconnect(reload_all_mods)
	reload_all_mods()

func kill():
	if health:
		health.set_cur(0)
