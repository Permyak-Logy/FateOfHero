class_name TempSlowdownEffect extends TempEffect

@export var mod_value: ModValue

func update_on_move(distance: float) -> float:
	return max(0, distance * (1 - mod_value.mul) - mod_value.add)
