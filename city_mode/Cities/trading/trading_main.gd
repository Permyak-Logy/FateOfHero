extends Control

class_name Trading

@export var trade1 : Item = null
@export var trade2 : Item = null
@export var trade3 : Item = null
@export var trade4 : Item = null
@export var trade5 : Item = null
@export var trade6 : Item = null
@export var trade7 : Item = null
@export var trade8 : Item = null
@export var trade9 : Item = null

func _ready():
	$HBoxContainer/NinePatchRect/Trades1.add_trade_item(trade1, trade2, trade3)
	$HBoxContainer/NinePatchRect/Trades2.add_trade_item(trade4, trade5, trade6)
	$HBoxContainer/NinePatchRect/Trades3.add_trade_item(trade7, trade8, trade9)
