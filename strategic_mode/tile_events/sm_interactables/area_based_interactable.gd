class_name AreaBasedInteractable extends TileEvent

var player_present: bool = false 

# wont change it's texture
func _ready():
	pass

func _input(event):
	if event.is_action_pressed("activate"):
		if player_present:
			activate() 

func _on_area_2d_body_entered(body):
	if not is_instance_of(body, CharacterBody2D): return
	print(global_position)
	player_present = true


func _on_area_2d_body_exited(body):
	if not is_instance_of(body, CharacterBody2D): return	
	print(global_position)
	player_present = false
