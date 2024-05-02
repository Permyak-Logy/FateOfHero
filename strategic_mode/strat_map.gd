class_name StratMap extends Node2D


# ingame time in minutes; changes by 30 every time player moves; when it reaches 1440 becomes zero 
@onready var time: int = 0
@onready var gui: StratMapGUI = $GUI
@onready var player: Player = $player
@onready var tilemap: StratTileMap = $StratTileMap


signal strat_map_loaded
signal time_changed(time: int)

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

func _ready():
	strat_map_loaded.emit()
