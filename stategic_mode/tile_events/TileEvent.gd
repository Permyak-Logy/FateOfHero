extends Node2D

func activate():
	pass	

func remove():
	var host = get_parent()
	host.remove_child(self)
