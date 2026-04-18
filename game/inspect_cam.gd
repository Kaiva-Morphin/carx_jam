extends Camera3D


func _ready() -> void:
	GLOBAL.inspect_cam = self
	GLOBAL.inspect_node = $InspectNode
