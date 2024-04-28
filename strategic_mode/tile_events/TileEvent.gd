extends Node2D


func activate():
	print("TODO -- redefine activate")
	remove()

func remove():
	var host = get_parent()
	host.remove_child(self)


