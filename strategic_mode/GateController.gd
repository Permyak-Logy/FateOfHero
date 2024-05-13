extends Node

@onready var gate: GateTileEvent = $Gate
@onready var encounter: Encounter = $GateEncounter

func _ready():
	encounter.removed.connect(gate.open)
