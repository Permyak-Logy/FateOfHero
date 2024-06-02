extends NinePatchRect

func open_description(description):
	if description != "":
		$".".visible = true
		$Label.text = description

func close_description():
	$".".visible = false
	$Label.text = ""
