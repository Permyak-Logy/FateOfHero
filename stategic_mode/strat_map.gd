extends Node2D

class_name StratMap


# ingame time in minutes; changes by 30 every time player moves; when it reaches 1440 becomes zero 
@onready var time: int = 0

@onready var player: Player = $player

signal time_changed(time)

func pause():
	get_tree().paused = true

func unpause():
	get_tree().paused = false

func move_time(delta: int):
	time += delta
	time = time % 1440
	time_changed.emit(time)


func _on_inventory_gui_inventory_opened():
	pause()

func _on_inventory_gui_inventory_closed():
	unpause()
