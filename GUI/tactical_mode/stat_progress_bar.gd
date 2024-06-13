class_name StatProgressBar extends ProgressBar

var min_max_stat_component: MinMaxStatComponent

func _process(_delta):
	if min_max_stat_component:
		set_value_no_signal(min_max_stat_component.percent() * 100)
