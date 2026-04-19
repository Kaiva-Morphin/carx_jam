extends Area3D
class_name Interactable

signal interaction_start
signal interaction_end

func _ready() -> void:
	pass

func hint() -> String:
	return ""

func interact() -> void:
	interaction_start.emit()
