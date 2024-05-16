extends Node2D

@export var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	anim.play("idle")
