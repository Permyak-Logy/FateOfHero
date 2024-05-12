extends Label

var place : int = 0:
	set(value):
		place = value
		
		text = "Можно продать предметов - " + str(place)
