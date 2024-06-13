class_name StratTileMap extends TileMap

signal occupied_changed(pos: Vector2i, state: bool)

var occupied: Array[Vector2i] = []


func set_walkable(pos: Vector2i, val: bool):
	var i = occupied.find(pos)
	if i == -1 and not val:
		occupied.push_back(pos)
		occupied_changed.emit(pos, val)
	if i >= 0 and val:
		occupied.pop_at(i)
		occupied_changed.emit(pos, val)
		
