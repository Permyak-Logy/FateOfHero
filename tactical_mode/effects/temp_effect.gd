class_name TempEffect extends Effect

@export var moves: int = 1

func update_on_move():
	moves -= 1
	if moves == 0:
		finished.emit()

