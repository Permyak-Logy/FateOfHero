extends Node2D


func _on_button_exit_crafting_pressed():
	get_tree().change_scene_to_file("res://city_mode/CityMap.tscn")
