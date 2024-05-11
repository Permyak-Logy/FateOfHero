class_name TacticalInfo extends Panel

@onready var rich_text_label: RichTextLabel = $RichTextLabel

func write(text: String):
	if rich_text_label.get_total_character_count() > 0:
		text = "\n" + text
	rich_text_label.add_text(text)

func clear():
	rich_text_label.text = ""
