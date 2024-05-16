extends Node2D

@export var anim: AnimationPlayer

func _ready():
	anim.play("idle")
