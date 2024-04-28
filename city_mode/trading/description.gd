extends NinePatchRect

func add_description(description, des):
	if des:
		$".".visible = true
		$Label.text = description
	elif $Label.text != description:
		$Label.text = description
	else:
		$".".visible = false
