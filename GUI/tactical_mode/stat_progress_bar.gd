extends ProgressBar

class_name StatProgressBar

var stat_component: StatComponent

func _process(_delta):
	if stat_component:
		set_value_no_signal(stat_component.percent() * 100)
