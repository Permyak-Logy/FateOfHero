class_name NarisUnit extends Unit

@onready var animation = $AnimationPlayer

func play(_name, _params=null):
	if _name in ["idle", "run"]:
		animation.play(_name)
	else:
		await super(_name, _params)
