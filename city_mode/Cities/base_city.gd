class_name City extends Node2D

"""
Base class for cities
All the shared logic goes here
The API must be defined here
"""
signal leave_city

@onready var trading_inventory: Inventory

func set_inventory(inventory: Inventory):
	trading_inventory = inventory
