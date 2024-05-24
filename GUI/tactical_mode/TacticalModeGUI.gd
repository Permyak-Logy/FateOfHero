class_name TacticalModeGUI extends CanvasLayer

@onready var hbox: HBoxContainer = $HBoxContainer
@onready var btn_ability = preload("res://GUI/tactical_mode/BtnAbility.tscn")
@onready var map: TacticalMap = $".."
@onready var btn_group: ButtonGroup = preload("res://GUI/tactical_mode/abilities_button_group.tres")
@onready var lbl_name: Label = $AbilityPanel/GridContainer/LabelName
@onready var lbl_desc: Label = $AbilityPanel/GridContainer/LabelDesc
@onready var ability_panel: Panel = $AbilityPanel
@onready var escape_ability_btn: W_BtnAbility = $EscapeAbility
@onready var tactical_info: TacticalInfo = $TacticalInfo
var selected: int = -1

func _ready():
	init_ability(escape_ability_btn, map.escape_ability)
	escape_ability_btn.hide()
	btn_group.pressed.connect(_on_pressed)
	ability_panel.hide()

func _exit_tree():
	ability_panel.hide()

func show_abilities(unit: Unit):
	clear_abilities()
	for ability in unit.get_abilities():
		var btn: W_BtnAbility = btn_ability.instantiate()
		init_ability(btn, ability)
		hbox.add_child(btn)
	escape_ability_btn.update()
	escape_ability_btn.show()

func init_ability(btn: W_BtnAbility, ability: Ability):
	btn.set_ability(ability)
	btn.button_group = btn_group
	btn.pressed.connect(_on_pressed)
	btn.mouse_entered.connect(func(): show_description(ability))
	btn.mouse_exited.connect(hide_description)

func show_description(ability: Ability):
	lbl_name.text = ability.name
	lbl_desc.text = ability.description
	ability_panel.show()

func hide_description():
	ability_panel.hide()

func clear_abilities():
	for btn in hbox.get_children():
		btn.queue_free()

func _on_selected(new_ability):
	if new_ability:
		for btn in btn_group.get_buttons():
			if (btn as W_BtnAbility).ability == new_ability:
				btn.set_pressed_no_signal(true)
	else:
		var btn = btn_group.get_pressed_button()
		if btn:
			btn.set_pressed_no_signal(false)

func _on_pressed(_null=null):
	var pressed_btn: W_BtnAbility = btn_group.get_pressed_button()
	if pressed_btn:
		if pressed_btn.ability != map.cur_ability:
			map._prepare_ability((pressed_btn as W_BtnAbility).ability)
	else:
		map._cancel_ability()

func update_queue(que: Array):
	# TODO: Меняй туть
	pass
