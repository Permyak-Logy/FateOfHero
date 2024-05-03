class_name LevelUpGUI extends Control

@onready var name_label: Label = $Panel/VBoxContainer/Title/Name
@onready var pts_label: Label = $Panel/VBoxContainer/PtsMsg/PtsLabel
@onready var character_sprite: Sprite2D = $Panel/VBoxContainer/CenterContainer/CharacterDisplay/CenterContainer/Sprite2D
@onready var stat_card_container: VBoxContainer = $Panel/VBoxContainer/CenterContainer/StatContainer

@onready var health_card: StatCard =  $Panel/VBoxContainer/CenterContainer/StatContainer/HP
@onready var speed_card : StatCard =  $Panel/VBoxContainer/CenterContainer/StatContainer/Speed
@onready var defence_card : StatCard =  $Panel/VBoxContainer/CenterContainer/StatContainer/Defence
@onready var damage_card : StatCard =  $Panel/VBoxContainer/CenterContainer/StatContainer/Atack

@onready var done_button = $Panel/VBoxContainer/Done
signal done
var unit: Unit = null


var names: Dictionary = {
	unit.health :  "HP ",
	unit.speed :   "SPD",
	unit.defence : "DEF",
	unit.damage :  "ATK",
}

var delta: Dictionary = {
	unit.health :  0,
	unit.speed :   0,
	unit.defence : 0,
	unit.damage :  0,
}

var std_d: Dictionary = {
	unit.health :  100,
	unit.speed :   2,
	unit.defence : 20,
	unit.damage :  20,
}

func setup_stat_card(stat_card: StatCard, comp: StatComponent):
	print(names[comp])
	stat_card.set_stat_name(names[comp])
	stat_card.set_value(comp.cur())
	
	var callable = Callable(increment)
	callable = callable.bind(comp)
	stat_card.plus_btn.pressed.connect(callable)
	
	callable = Callable(decrement)
	callable = callable.bind(comp)
	stat_card.minus_btn.pressed.connect(callable)

func _ready():
	assert(unit != null, "pass unit before attaching")
	var callable: Callable
	setup_stat_card(health_card, unit.health)
	setup_stat_card(speed_card, unit.speed)
	setup_stat_card(defence_card, unit.defence)
	setup_stat_card(damage_card, unit.damage)
	done_button.pressed.connect(commit)

func increment(comp: StatComponent):
	delta[comp] += std_d[comp]
	update()

func decrement(comp: StatComponent):
	delta[comp] -= std_d[comp]
	update()


# graphical update
func update():
	health_card.set_value(unit.health.cur() + delta[unit.health])
	speed_card.set_value(unit.speed.cur() + delta[unit.speed])
	defence_card.set_value(unit.defence.cur() + delta[unit.defence])
	damage_card.set_value(unit.damage.cur() + delta[unit.damage])

func commit():
	unit.health.rebase(unit.health.cur() + delta[unit.health])
	unit.speed.rebase(unit.speed.cur() + delta[unit.speed])
	unit.defence.rebase(unit.defence.cur() + delta[unit.defence])
	unit.damage.rebase(unit.damage.cur() + delta[unit.damage])
	done.emit()
