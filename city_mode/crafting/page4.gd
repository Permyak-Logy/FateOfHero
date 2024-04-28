extends Button



func _on_pressed():
	$"../../HBoxContainer/craft1".visible = false
	$"../../HBoxContainer/craft2".visible = false
	$"../../HBoxContainer/craft3".visible = false
	$"../../HBoxContainer/craft4".visible = true
	$"../../HBoxContainer/craft5".visible = false
	$"../page1/button_back".frame = 0
	$"../page2/button_back".frame = 0
	$"../page3/button_back".frame = 0
	$"../page4/button_back".frame = 1
	$"../page5/button_back".frame = 0
