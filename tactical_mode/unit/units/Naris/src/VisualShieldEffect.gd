extends Node2D

@export var anim: AnimationPlayer

func _ready():
	await anim.play("idle")
