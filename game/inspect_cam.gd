extends Camera3D


func _ready() -> void:
	GLOBAL.inspect_cam = self
	GLOBAL.inspect_node = $InspectNode

func _physics_process(_dt: float) -> void:
	var c = $RayCast3D.get_collider()
	#GLOBAL.hint_node.hide()
	$"../../../InspectHint".hide()
	if !c || !c.is_in_group("inspectable_interactable"): return
	$"../../../InspectHint".show()
	$"../../../InspectHint".text = "E - interact"
	if Input.is_action_just_pressed("interact"):
		c.interact()
