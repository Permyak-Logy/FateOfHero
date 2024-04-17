extends Node2D

class_name BasePuzzle

signal solved

func start():
	print(" ! Redefine start") 
	solved.emit()
