class_name SmolIttoUnit extends Unit

@onready var tile_map = $"../TileMap"

var current_id_path: Array = []

signal walk_finished

var heal_one_ability = HealOneAbility.new()
var heal_team_ability = HealTeamAbility.new()

func get_abilities():
	return [attack_ability, heal_one_ability, heal_team_ability] + inventory.get_abilities()

func play(_name, params=null):
	if _name == "walk":
		current_id_path = params
		await walk_finished
	else:
		super.play(_name)

func _physics_process(_delta):
	if current_id_path.is_empty():
		return

	var target_position = tile_map.map_to_local(current_id_path.front())
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
