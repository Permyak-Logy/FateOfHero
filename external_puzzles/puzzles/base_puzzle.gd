class_name BasePuzzle extends Node2D

"""
Base class for puzzles
All the shared logic goes here
The API must be defined here
"""

var rewards: Array[ItemStack] = []
signal solved(rewards: Array[ItemStack])
signal failed(rewards: Array[ItemStack])
