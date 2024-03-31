extends Node2D


func activate():
	remove()

func remove():
	var host = get_parent()
	host.remove_child(self)
