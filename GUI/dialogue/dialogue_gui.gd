class_name DialogueGUI extends Control

"""
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
		
	for opt in dialogue.options:
		var option = opt.instantiate()
		var btn = Button.new()
		option_container.add_child(btn)
		btn.text = option.msg 
		var callable = Callable(on_option_pressed)
		callable = callable.bind(option)
		btn.pressed.connect(callable)

func on_option_pressed(option: DialogueOption):
	option.activate()
	if option.next_dialogue:
		change_dialogue(option.next_dialogue)
	else:
		
		dialogue_finished.emit()
		

#func _ready():
	#visible = false
	
