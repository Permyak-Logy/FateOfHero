class_name ProceduralStratMap extends StratMap

@onready var noise_img: Sprite2D = $Sprite2D

func _ready():
	tilemap = (tilemap as ProcTileMap)
	gui.gui_opened.connect(on_gui_opened)
	gui.gui_closed.connect(on_gui_closed)
	player.moved.connect(tilemap.on_player_moved)
	if not tilemap.drawn_scs.is_empty():
		strat_map_loaded.emit()
		tilemap.superchunk_generated.connect(player.gen_nav)
		tilemap.start_generation_job()
