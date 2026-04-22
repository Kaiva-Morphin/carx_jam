extends Camera3D


func _ready() -> void:
	GLOBAL.inspect_cam = self
	GLOBAL.inspect_node = $"../../InspectNode"
	GLOBAL.inspect_cam_joint = $".."
	$"../../../DirectionalLight3D".show()

func _physics_process(_dt: float) -> void:
	var c = $RayCast3D.get_collider()
	if !c || !c.is_in_group("inspectable_interactible"):
		GLOBAL.hints.rm_center_hint()
		return
	else:
		GLOBAL.hints.center_hint(c.hint_keymap(), c.hint())
		if Input.is_action_just_pressed("interact"):
			c.interact()
