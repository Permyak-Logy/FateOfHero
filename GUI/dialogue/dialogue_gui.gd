class_name DialogueGUI extends Control

"""
Dialog window 
It does not own itself
you must create it and destroy it
when dialog is ower, signal dialog finished will be emitted
note, that it is not flexable
"""

@onready var option_container: VBoxContainer = $VBoxContainer/OptionContainer
@onready var title: Label = $VBoxContainer/TitleHighlight/Title
@onready var body: RichTextLabel = $VBoxContainer/BodyHighlight/RichTextLabel


signal dialogue_finished

func change_dialogue(dialogue: Dialogue):
	print(dialogue.title)
	title.text = dialogue.title
	body.text = dialogue.msg
	
	for old_option in option_container.get_children():
		option_container.remove_child(old_option)
	
	var new_size = custom_minimum_size
	for opt in dialogue.options:
		var option = opt.instantiate()
		var btn = Button.new()
		btn.add_child(option)
		option_container.add_child(btn)
		if not option.is_awailable():
			option_container.remove_child(btn)
			continue
		btn.text = option.msg 
		var callable = Callable(on_option_pressed)
		callable = callable.bind(option)
		btn.pressed.connect(callable)
		new_size += Vector2(0, 7) +  Vector2(0, 30)  + Vector2 (0, 22) * (btn.text.count("\n"))
	set_size(new_size)

func on_option_pressed(option: DialogueOption):
	option.dialog_action_done.connect(on_dialog_action_done)
	visible = false
	option.activate()

func on_dialog_action_done(next_dialogue: Dialogue):
	visible = true
	if next_dialogue:
		change_dialogue(next_dialogue)
	else:
		dialogue_finished.emit()
