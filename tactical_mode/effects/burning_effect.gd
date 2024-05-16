class_name BuriningEffect extends TempEffect

@export var scaling_type: Mod.Type
@export var power: ModValue

var scale: float:
	get:
		return (instigator as Unit).stat_from_type(scaling_type).cur()

func on_set_owner(old, new):
	if owner:
		get_map().write_info("-> " + owner.unit_name + " горит")
		await owner.apply_damage(scale * power.mul + power.add, instigator)

func update_on_start_stepmove():
	get_map().write_info("-> " + owner.unit_name + " горит")
	await owner.apply_damage(scale * power.mul + power.add, instigator)
	
	super()
