extends Node

@onready var gate: GateTileEvent = $Gate
@onready var encounter: Encounter = $GateEncounter

func _ready():
	if encounter:
		encounter.removed.connect(gate.open)
