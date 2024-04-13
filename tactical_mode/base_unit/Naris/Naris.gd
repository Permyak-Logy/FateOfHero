class_name NarisUnit extends Unit

@onready var animation = $AnimationPlayer

var current_id_path: Array = []

signal walk_finished

var my_defense_ability = MyDefenseAbility.new()
var hidden_armor_ability = HiddenArmorAbility.new()

func get_abilities():
	return [attack_ability, my_defense_ability, hidden_armor_ability] + inventory.get_abilities()

func play(_name, _params=null):
	if _name == "walk":
		current_id_path = _params
		await walk_finished
	else:
		super.play(_name)

func _physics_process(_delta):
	if current_id_path.is_empty():
		animation.play("idle")
		return

	var target_position = $"../TileMap".map_to_local(current_id_path.front())
	animation.play("run")
	
	if ((target_position - global_position)[0] < 0) != ($Sprite2D.scale[0] < 0):
		$Sprite2D.scale[0] = -$Sprite2D.scale[0]
	
	if ((target_position - global_position) as Vector2).length() < 2:
		global_position = target_position
	else:
		($"." as CharacterBody2D).velocity = ((target_position - global_position) as Vector2).normalized() * 200
		($"." as CharacterBody2D).move_and_slide()
	
	if global_position == target_position:    
		current_id_path.pop_front()
		if not current_id_path:
			$Sprite2D.scale = Vector2(1, 1)
			walk_finished.emit()
