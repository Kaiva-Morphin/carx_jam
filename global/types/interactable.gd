extends Area3D
class_name Interactable

signal interaction_start
signal interaction_end

func _ready() -> void:
	add_to_group("interactible")
	self.collision_layer = 4
	self.collision_mask = 4

func hint() -> String:
	return ""

func interact() -> void:
	interaction_start.emit()
