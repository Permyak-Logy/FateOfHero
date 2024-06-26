class_name StratMap extends Node2D

# ingame time in minutes; changes by 30 every time player moves; when it reaches 1440 becomes zero 
@onready var gui: StratMapGUI = $GUI
@onready var tilemap: StratTileMap = $StratTileMap
@onready var player: Player = $player
@onready var game: Game = get_tree().root.get_child(0)

var GameOverGUIRes: PackedScene = preload("res://GUI/game_over/game_over_gui.tscn")
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

func show_game_over():
	var game_over_gui: GameOverGUI = GameOverGUIRes.instantiate() 
	gui.add_child(game_over_gui)
	game_over_gui.set_lose()
	await game_over_gui.done
	gui.remove_child(game_over_gui)
	game.remove_save()
	game.to_main_menu()

func show_win():
	var game_over_gui: GameOverGUI = GameOverGUIRes.instantiate() 
	gui.add_child(game_over_gui)
	game_over_gui.set_win()
	await game_over_gui.done
	gui.remove_child(game_over_gui)
