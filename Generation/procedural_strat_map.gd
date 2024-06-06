class_name ProceduralStratMap extends StratMap

func _ready():
	gui.gui_opened.connect(on_gui_opened)
	gui.gui_closed.connect(on_gui_closed)
