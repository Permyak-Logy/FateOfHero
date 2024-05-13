class_name TileEvent extends Node2D

"""
Base class for any TileEvents
"""

@export var texture: Texture2D
@export var doflip: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	sprite.texture = texture
	sprite.flip_v = doflip

func activate():
	print("TODO -- redefine activate")
	remove()

func remove():
	var host = get_parent()
	if host:
		host.remove_child(self)


