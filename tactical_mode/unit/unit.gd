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
@export var trail_particles: GPUParticles2D = null
@export var health_bar_pb: StatProgressBar = null
@export var animation_player: AnimationPlayer = null
@export var flip_onready: bool = false

@export_group("Unit stats")
@export var acts_count: int = 1
@export var controlled_player: bool = true

@export_group("Unit abilities")
@export var private_abilities: Array[Ability] = []:
	set(value):
		private_abilities = value.duplicate(true)
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
const DEFAULT_COLOR = Vector4(0, 0, 0, 100)
const TO_SELECT_COLOR = Vector4(255, 255, 0, 100)

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
	get_map().write_info(
		"=> " + unit_name + " получил " + str(_damage) +" урона от " + _instigator.unit_name
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

func ai(map: TacticalMap):
	map.acts = 0

func get_occupied_cells() -> Array[Vector2i]:
	if visible:
		return [get_cell()]
	return []

func prepare_fight():
	if animation_player:
		animation_player.animation_set_next("attack", "idle")
		animation_player.animation_set_next("ability", "idle")
	
	print("=> Prepare: ", unit_name)
	while _effects:
		remove_effect(_effects[0])
	
	reload_all_mods()
	for ability in get_abilities():
		ability.set_owner(self)
		ability.reset()
	apply_passives()
	flipped = idle_direction_bool()
	play("idle")

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
	sprite_for_outline.flip_h = bool(int(flipped) ^ int(flip_onready))

func _physics_process(_delta):
	if current_id_path.is_empty():
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
			play("idle")

func idle_direction_bool():
	return get_map().is_enemy(self)
	
func play(_name: String, _params=null):
	if _name == "walk":
		current_id_path = _params
		await walk_finished
	elif animation_player:
		animation_player.play(_name)
		await animation_player.animation_changed

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
	if effect.stackable:
		for other in get_effects():
			if effect.get_class() == other.get_class() and other.stackable:
				if other.stack(effect):
					get_map().write_info(
						"=> " + self.unit_name + " обновил эффект " + other.effect_name
					)
					reload_all_mods()
					return
	
	get_map().write_info("=> " + self.unit_name + " получил эффект " + effect.effect_name)
	_effects.append(effect)
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
	reload_all_mods()

func kill():
	if health:
		health.set_cur(0)
