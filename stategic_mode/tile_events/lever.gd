extends "res://stategic_mode/tile_events/TileEvent.gd"

class_name LeverTileEntity
@export var id: int 
@export var state: bool = false

@onready var sprite = $Sprite2D
@onready var collider = $EventCollider

var player_present: bool = false 

func change_state():
	state = not state
	sprite.frame = int(state)
	print("lever ", id, " pulled to ", state)
	get_parent().update_state(id, state)
	

func activate():
	pass

func _input(event):
	if event.is_action_pressed("activate"):
		if player_present:
			change_state()

func _on_area_2d_body_entered(body):
	if not is_instance_of(body, CharacterBody2D): return
	print(global_position)
	player_present = true


func _on_area_2d_body_exited(body):
	if not is_instance_of(body, CharacterBody2D): return	
	print(global_position)
	player_present = false
