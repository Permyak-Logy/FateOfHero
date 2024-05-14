class_name Unit extends Actor

var outline_shader = preload("res://tactical_mode/assets/outline_shader.tres")

@export var unit_name: String = "Unit"

@export_group("Components")
@export var inventory: InventoryComponent = null
@export var health: StatComponent = null:
	set(value):
		if health:
			health.empty.disconnect(on_death)
		health = value
		if health:
			health.empty.connect(on_death)
@export var defence: StatComponent = null
@export var speed: StatComponent = null
@export var damage: StatComponent = null
@export var expirience: ExpirienceComponent = null
@export var sprite_for_outline: Sprite2D = null
@export var trail_particles: GPUParticles2D = null
@export var health_bar_pb: StatProgressBar = null
@export var animation_player: AnimationPlayer = null
@export var flip_onready: bool = false
@export var for_flip_sprites: Array[Sprite2D] = []

@export_group("Unit stats")
@export var acts_count: int = 1
@export var controlled_player: bool = true

@export_group("Unit abilities")
@export var private_abilities: Array[Ability] = []
@export var private_passives: Array[Effect] = []

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

# Различные цвета для обводки
const PLAYER_COLOR = Vector4(0, 255, 0, 100)
const CUR_COLOR = Vector4(255, 255, 255, 100)
const SELECTED_COLOR = Vector4(0, 0, 255, 100)
const ENEMY_COLOR = Vector4(255, 0, 0, 100)
const DEFAULT_COLOR = Vector4(0, 0, 0, 0)
const TO_SELECT_COLOR = Vector4(255, 255, 0, 100)

# Слайд для передвижения между целью
var _start_pos: Vector2
var _end_pos = Vector2(0, 0)

@export_group("For Animation")
@export var percent_between_target: float = 0:
	set(value):
		if value != percent_between_target:
			global_position = _start_pos + (_end_pos - _start_pos) * value
			flipped = bool(int(percent_between_target > value) ^ int((_end_pos - _start_pos)[0] < 0))
			percent_between_target = value

func _ready():
	if health and health_bar_pb:
		health_bar_pb.stat_component = health
	set_outline_color(DEFAULT_COLOR)
	if flip_onready:
		on_flip_unit()

func set_outline_color(color: Vector4):
	"""
	Устанавливает цвет обводки (необходимо чтобы был определён sprite_for_outline)
	"""
	if (sprite_for_outline == null) or not (sprite_for_outline.material as ShaderMaterial):
		return
	(sprite_for_outline.material as ShaderMaterial).set_shader_parameter(
		"outline_color", color)

func toggle_preview(value: bool):
	if value:
		set_outline_color(DEFAULT_COLOR)
	health_bar_pb.visible = not value

func apply_damage(_damage: float, _instigator: Unit):
	"""
	Применяет урон в размере _damage от _instigator с учётом наложенных эффектов
	предметов, сопротивлений и т.д.
	"""
	if is_death():
		return 0
	
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
	await play("damaged")
	health.sub(_damage)
	get_map().write_info(
		"=> " + unit_name + " получил " + str(int(_damage)) +" урона от " + _instigator.unit_name
	)
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
		return private_abilities + inventory.get_abilities()
	return private_abilities

func apply_passives():
	for effect in private_passives:
		var passive: Effect = effect.duplicate(true)
		passive.instigator = self
		add_effect(passive)


func get_occupied_cells() -> Array[Vector2i]:
	if visible:
		return [get_cell()]
	return []

func prepare_fight():
	toggle_preview(false)
	death.connect(get_map().on_kill)
	print("=> Prepare: ", unit_name)
	reload_all_mods()
	for ability in get_abilities():
		ability.set_owner(self)
		ability.reset()
	apply_passives()
	flipped = idle_direction_bool()
	play("idle")
	get_map().reset_outline_color(self)

func premove_update():
	for ability in get_abilities():
		ability.update()
	for effect in get_effects():
		effect.update_on_start_stepmove()

func on_flip_unit():
	if trail_particles:
		var i: Image = trail_particles.texture.get_image()
		i.flip_x()
		trail_particles.texture = ImageTexture.create_from_image(i)
	for sprite in for_flip_sprites:
		sprite.flip_h = bool(int(flipped) ^ int(flip_onready))

func _physics_process(_delta):
	if current_id_path.is_empty():
		return

	var target_position = $"../TileMap".map_to_local(current_id_path.front())

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
			play("idle")

func idle_direction_bool():
	return get_map().is_enemy(self)
	
func play(_name: String, _params=null):
	print(unit_name, " play ", _name, " ", _params)
	if is_death() and not _name.begins_with("death"):
		return
	if _name == "walk":
		current_id_path = _params
		play("run")
		await walk_finished
	elif animation_player:
		if not animation_player.has_animation(_name):
			print(self, "not have animation ", _name)
			return
		if (_name == "preattack" or _name == "ability") and _params:
			_start_pos = global_position
			_end_pos = (_params as Unit).global_position
			_end_pos += Vector2((1 if _start_pos[0] - _end_pos[0] > 0 else -1) * 16, 5)
		
		if animation_player.has_animation("RESET") and not _name.begins_with("post"):
			animation_player.animation_set_next("RESET", _name)
			animation_player.play("RESET")
		else:
			animation_player.play(_name)
		await animation_player.animation_finished
		
		if _name.begins_with("post"):
			flipped = idle_direction_bool()
	else:
		print(self, " not Animation player")

func on_death(_component: StatComponent):
	print("Death ", self)
	play("death")
	death.emit(self)

func is_death() -> bool:
	if not health:
		return false
	return health.cur() <= 0

func _on_toggle_select(_viewport, event: InputEvent, _shape_idx: int):
	if not get_map() or get_map()._block_input:
		return
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
	if event.is_action_pressed("about_unit"):
		get_map().write_info(
			"-> " + unit_name + " (" + str(expirience.level) + " ур.)" +
			" ХП=" + str(int(health.cur())) + "/" + str(int(health.get_max()))
		)

func _on_mouse_entered():
	var ability = get_map().cur_ability
	if not ability or not is_instance_of(ability, DirectedAbility):
		return
	if not ability.can_select(self):
		return
	set_outline_color(TO_SELECT_COLOR)

func _on_mouse_exited():
	get_map().reset_outline_color(self)

func get_effects() -> Array[Effect]:
	return _effects

func add_effect(effect: Effect):
	if is_death() or not visible:
		return
	if effect.stackable:
		for other in get_effects():
			if effect.get_class() != other.get_class():
				continue
			if not other.stackable:
				continue
			if effect.effect_name != other.effect_name:
				continue
			if other.stack(effect):
				get_map().write_info(
					"=> " + self.unit_name + " обновил эффект " + other.effect_name
				)
				reload_all_mods()
				return
	
	get_map().write_info("=> " + self.unit_name + " получил эффект " + effect.effect_name)
	_effects.insert(0, effect)
	effect.owner = self
	effect.finished.connect(remove_effect)
	effect.updated_mods.connect(reload_all_mods)
	reload_all_mods()

func remove_effect(effect: Effect):
	get_map().write_info(
		"=> " + " Кончился эффект " + effect.effect_name + " (" +unit_name + ")"
	)
	_effects.erase(effect)
	effect.finished.disconnect(remove_effect)
	effect.updated_mods.disconnect(reload_all_mods)
	effect.remove_visual_effect()
	effect.cancel_effect()
	reload_all_mods()

func kill():
	if health:
		health.set_cur(0)

func get_move_distance() -> int:
	var distance = (speed.cur() - 100) / 20 + 4
	for effect in get_effects():
		distance = effect.update_on_move(distance)
	return int(distance)

func ai(map: TacticalMap):
	ai_random_move(map)

func ai_random_move(map: TacticalMap):
	var distance = get_move_distance()
	var rng = RandomNumberGenerator.new()
	var path = []
	var cell = Vector2i(-1, -1)
	while not map.can_move_to(cell):
		cell = map.to_map(global_position) + Vector2i(
			rng.randi_range(-distance, distance),
			rng.randi_range(-distance, distance)
		)
	map.select_path_to(cell)
	map._move_active_unit()

func ai_move_to(map: TacticalMap, cell: Vector2i):
	var cells = map.walkable_fill()
	cells.append(cell)
	var astar = AStarHexagon2D.new(cells)
	var path = astar.get_id_path(astar.mti(get_cell()), astar.mti(cell))
	while not map.can_move_to(astar.itm(path[len(path) - 1])):
		path.remove_at(len(path) - 1)
	map.select_path_to(astar.itm(path[len(path) - 1]))
	map._move_active_unit()

func ai_pass(map: TacticalMap):
	map.acts = 0
	map._update_stepmove()

func reset_color():
	get_map().reset_outline_color(self)

func stat_from_type(t: Mod.Type) -> StatComponent:
	if t == Mod.Type.Health:
		return health
	elif t == Mod.Type.Defence:
		return defence
	elif t == Mod.Type.Damage:
		return damage
	elif t == Mod.Type.Speed:
		return speed
	elif t == Mod.Type.None:
		return null
	assert(false, "Неопределён компонент для скейлинга для " + unit_name)
	return null
