class_name TownTileEvent extends "res://strategic_mode/tile_events/TileEvent.gd"


@onready var sprite: Sprite2D = $Sprite2D
@onready var game: Game = get_tree().root.get_child(0)

@export var city: PackedScene
@export var texture: Texture2D

var player_present = false

func _ready():
	sprite.texture = texture

func activate():
	var city_scene: City = city.instantiate()
	city_scene.leave_city.connect(on_done)
	game.city_container.add_child(city_scene)
	game.to_city_mode()

func on_done():
	game.to_strat_mode()
	pass

func _input(event):
	if event.is_action_pressed("activate") and player_present:
		activate()


func _on_area_2d_body_exited(body):
	if not is_instance_of(body, Player): return	
	player_present = false
	
func _on_area_2d_body_entered(body):
	if not is_instance_of(body, Player): return
	player_present = true
