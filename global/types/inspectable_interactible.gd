extends Interactible
class_name InspectableInteractible



func _ready() -> void:
	collision_layer = 8
	collision_mask = 8
	add_to_group("inspectable_interactible")

func interact():
	super.interact()
