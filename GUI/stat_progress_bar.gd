extends ProgressBar

class_name StatProgressBar

@export var stat_component: StatComponent


func _process(delta):
	set_value_no_signal(stat_component.percent() * 100)
