class_name Eated extends BlockMovingEffect


func on_set_owner(old, new):
	if old:
		old.show()
	if new:
		new.hide()

func cancel_effect():
	if owner:
		owner.show()
