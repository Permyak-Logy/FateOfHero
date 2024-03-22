extends Resource

class_name Mod

enum Type {Health, Speed, Damage, Defence, None}

@export var type: Type = Type.None
@export var value: ModValue = ModValue.new()
