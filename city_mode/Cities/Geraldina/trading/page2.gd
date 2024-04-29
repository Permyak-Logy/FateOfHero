extends Button



func _on_pressed():
	$"../../HBoxContainer/NinePatchRect/Trades1".visible = false
	$"../../HBoxContainer/NinePatchRect/Trades2".visible = true
	$"../../HBoxContainer/NinePatchRect/Trades2".visible = false
	$"../../HBoxContainer/NinePatchRect/Trades2".visible = false
	$"../../HBoxContainer/NinePatchRect/Trades2".visible = false
	$"../page1/Sprite2D".frame = 0
	$"../page2/Sprite2D".frame = 1
	$"../page3/Sprite2D".frame = 0
	$"../page4/Sprite2D".frame = 0
	$"../page5/Sprite2D".frame = 0
