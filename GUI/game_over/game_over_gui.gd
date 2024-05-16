class_name GameOverGUI extends Control

@onready var title: Label = $Panel/VBoxContainer/Title
@onready var body: RichTextLabel = $Panel/VBoxContainer/Panel/Body
@onready var game: Game = get_tree().root.get_child(0)

signal done

func _on_to_main_menu_pressed():
	done.emit()

func set_win():
	title.text = "Победа!"
	body.text = "Игра окончена"

func set_lose():
	title.text = "Игра окончена"
	body.text = "Главный герой умер"
