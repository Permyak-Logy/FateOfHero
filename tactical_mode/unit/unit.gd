class_name Unit extends Actor

var outline_shader = preload("res://tactical_mode/assets/outline_shader.tres")

@export var unit_name: String = "Unit"

@export_group("Components")
@export var inventory: InventoryComponent = null:
	set(value):
		inventory = value.duplicate(true) if value else null
@export var health: StatComponent = null:
	set(value):
		if health:
			health.empty.disconnect(on_death)
		health = value.duplicate(true) if value else null
		if health:		
			health.empty.connect(on_death)
@export var defence: StatComponent = null:
	set(value):
		defence = value.duplicate(true) if value else null
@export var speed: StatComponent = null:
	set(value):
		speed = value.duplicate(true) if value else null
@export var damage: StatComponent = null:
	set(value):
		damage = value.duplicate(true) if value else null
@export var expirience: ExpirienceComponent = null:
	set(value):
		expirience = value.duplicate(true) if value else null
@export var sprite_for_outline: Sprite2D = null:
	set(value):
		sprite_for_outline = value
		(sprite_for_outline as CanvasItem).material = outline_shader.duplicate()
@export var trail_particles: GPUParticles2D = null:
	set(value):
		trail_particles = value
		trail_particles.hide()
@export var health_bar_pb: StatProgressBar = null

@export_group("Unit stats")
@export var acts_count: int = 1
@export var controlled_player: bool = true

@export_group("Unit abilities")
@export var private_abilities: Array[Ability] = []:
	set(value):
		private_abilities = value.duplicate(true)
@export var private_passives: Array[Effect] = []
var _abilities: Array[Ability] = []  # Текущие способности

signal death(Unit)  # Вызывается при смерти
signal walk_finished  # Вызывается при завершении передвижения

var current_id_path: Array = []  # Путь для передвижения

var _effects: Array[Effect] = []

var flipped: bool = false:  # Переключатель поворота
	set(value):
		if flipped != value:
			flipped = value
			on_flip_unit()
		else:
			flipped = value


var timer_for_walk_trail: SceneTreeTimer = null  # Таймер отключения walk_trail

# Различные цвета для обводки
const PLAYER_COLOR = Vector4(0, 255, 0, 100)
const CUR_COLOR = Vector4(255, 255, 255, 100)
const SELECTED_COLOR = Vector4(0, 0, 255, 100)
const ENEMY_COLOR = Vector4(255, 0, 0, 100)
const DEFAULT_COLOR = Vector4(0, 0, 0, 100)
const ESCAPE_COLOR = Vector4(255, 255, 0, 100)

func _ready():
	if health and health_bar_pb:
		health_bar_pb.stat_component = health
	set_outline_color(DEFAULT_COLOR)

func set_outline_color(color: Vector4):
	"""
	Устанавливает цвет обводки (необходимо чтобы был определён sprite_for_outline)
	"""
	if (sprite_for_outline == null):
		return
	(sprite_for_outline.material as ShaderMaterial).set_shader_parameter(
		"outline_color", color)
		
func apply_damage(_damage: float, _instigator: Unit = null):
	"""
	Применяет урон в размере _damage от _instigator с учётом наложенных эффектов
	предметов, сопротивлений и т.д.
	"""
	
	if _instigator:
		for effect in _instigator.get_effects():
			_damage = effect.update_on_attack(_damage, self)
	
	if not health:
		return 0
	
	if defence:
		_damage *= exp(-defence.cur() / 1500)
	
	for effect in get_effects():
		_damage = effect.update_on_damage(_damage, _instigator)
	
	_damage = max(_damage, 0)
	health.sub(_damage)
	print("=> ", unit_name, " получил ", _damage, " урона от ", _instigator.unit_name)
	return _damage

func reload_all_mods():
	"""
	Перезагружает все StatComponents
	"""
	
	for comp in [speed, health, defence, damage]:
		if comp:
			comp.reload_mods(self)

func get_mods() -> Dictionary:
	var all_mods: Dictionary
	if inventory:
		all_mods = inventory.get_mods()
	else:
		all_mods = {}
	for effect in _effects:
		for mod in effect.get_mods():
			if mod.type in all_mods:
				all_mods[(mod as Mod).type].iadd((mod as Mod).value)
			else:
				all_mods[(mod as Mod).type] = (mod as Mod).value.duplicate(true)
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
	flipped = idle_direction_bool()

func premove_update():
	for ability in get_abilities():
		ability.update()
	for effect in get_effects():
		effect.update_on_move()

func on_flip_unit():
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
		flipped = idle_direction_bool()
	else:
		flipped = (target_position - global_position)[0] < 0

	global_position = global_position.move_toward(target_position, 3)
	
	if global_position == target_position:    
		current_id_path.pop_front()
		if not current_id_path:
			flipped = idle_direction_bool()
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
