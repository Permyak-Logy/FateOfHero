extends "res://external_puzzles/puzzles/base_puzzle.gd"

class_name SafePath
@onready var inventory: Inventory = preload("res://inventory/global_inventory.tres")
@onready var tilemap: TileMap = $TileMap
@onready var player = $player
@onready var game: Game = get_tree().root.get_child(0)

var enemies: Array[PackedScene]


func _ready():
	player.global_position = tilemap.map_to_local(player.pos)

func start_fight():
	var characters = inventory.characters
	game.tactical_map.reinit(characters, enemies)
	game.to_tact_mode()
	game.tactical_map.finish.connect(on_finish_tactical_map)

func on_finish_tactical_map(alive: Array[PackedScene], dead: Array[PackedScene]):
	inventory.characters = alive
	solved.emit()
	game.to_strat_mode()
