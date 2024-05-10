class_name StratMap extends Node2D

# ingame time in minutes; changes by 30 every time player moves; when it reaches 1440 becomes zero 
@onready var gui: StratMapGUI = $GUI
@onready var tilemap: StratTileMap = $StratTileMap
@onready var player: Player = $player

var time: int = 0

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


func on_gui_opened():
	pause()

func on_gui_closed():
	unpause()

func _ready():
	gui.gui_opened.connect(on_gui_opened)
	gui.gui_closed.connect(on_gui_closed)
	strat_map_loaded.emit()


func _enter_tree():
	pass
