class_name TileEvent extends Node2D

"""
Base class for any TileEvents
"""

@export var texture: Texture2D
@export var doflip: bool = false

@onready var sprite: Sprite2D = $Sprite2D

signal removed(tile_event: TileEvent)

func _ready():
	sprite.texture = texture
	sprite.flip_h = doflip

func activate():
	print("TODO -- redefine activate")
	remove()

func remove(_none = null):
	var host = get_parent()
	if host:
		host.remove_child(self)
		removed.emit(self)


