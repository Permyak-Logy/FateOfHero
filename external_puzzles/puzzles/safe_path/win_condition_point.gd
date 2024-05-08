class_name EPWinCondition extends Node2D 

signal WCReached

func activate():
	WCReached.emit()
	queue_free()
