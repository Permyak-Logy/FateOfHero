class_name GameOverGUI extends Control

@onready var title: Label = $Panel/VBoxContainer/Title
@onready var body: RichTextLabel = $Panel/VBoxContainer/Panel/Body
@onready var game: Game = get_tree().root.get_child(0)

signal done

func _on_to_main_menu_pressed():
	done.emit()
