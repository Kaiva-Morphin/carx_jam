extends Interactible
class_name InspectableInteractible



func _ready() -> void:
	collision_layer = 8
	collision_mask = 8
	add_to_group("inspectable_interactible")
	
	if need_hint_:
		_hint_node = GLOBAL.visual_hint.instantiate()
		$"../../../Prop".add_child(_hint_node)
		_hint_node.position.y = 0.0

func interact():
	super.interact()
	if one_shoot:
		if _hint_node:
			_hint_node.queue_free()
			_hint_node = null
