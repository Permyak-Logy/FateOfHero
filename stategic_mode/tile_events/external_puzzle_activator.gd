extends "res://stategic_mode/tile_events/TileEvent.gd"

@onready var sprite: Sprite2D = $Sprite2D
@onready var game: Game = get_tree().root.get_child(0)

@export var puzzle: PackedScene
@export var texture: Texture2D

func _ready():
	sprite.texture = texture

func activate():
	var puzzle_scene: BasePuzzle = puzzle.instantiate()
	puzzle_scene.start()
	puzzle_scene.solved.connect(on_done)
	remove()
	game.external_puzzle_container.add_child(puzzle_scene)
	game.to_puzzle_mode()

func on_done():
	game.to_strat_mode()
	pass
