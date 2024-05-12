class_name TownTileEvent extends TileEvent

"""
Tile Event for switching into the city_mode
activate is called when "activate"(f) is pressed and player is in the area of the tile event
"""

@onready var game: Game = get_tree().root.get_child(0)

@export var city: PackedScene
@export var city_inventory: Inventory

var player_present = false

func activate():
	assert(city != null, "You forgot ot enter the town")
	var city_scene: City = city.instantiate()
	city_scene.leave_city.connect(on_done)
	game.city_container.add_child(city_scene)
	city_scene.inventory = city_inventory
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
