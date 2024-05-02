class_name StratTileMap extends TileMap

signal strat_map_walkability_changed

func set_walkable(pos: Vector2i, val: bool):
	if get_cell_tile_data(0, pos).get_custom_data("walkable") == val:
		return 
	get_cell_tile_data(0, pos).set_custom_data("walkable", val)
	strat_map_walkability_changed.emit()
