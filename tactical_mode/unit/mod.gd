class_name Mod extends Resource

enum Type {Health, Speed, Damage, Defence, None}

@export var type: Type = Type.None
@export var value: ModValue = ModValue.new()
