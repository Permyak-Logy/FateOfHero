class_name City extends Node2D

"""
Shared ancestor of all cities
"""
@onready var craftingGUI : CraftingGUI = $crafting
@onready var tradingGUI : TradingGUI = $Trading


signal leave_city

func pause():
	get_tree().paused = true

func unpause():
	get_tree().paused = false

