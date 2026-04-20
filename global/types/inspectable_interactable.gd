extends Area3D
class_name InspectableInteractable



func _ready() -> void:
	collision_layer = 8
	collision_mask = 8
	add_to_group("inspectable_interactable")

func interact():
	pass
