extends CSGCombiner3D


func _ready() -> void:
	var s = $".".bake_collision_shape()
	var b := StaticBody3D.new()
	var c := CollisionShape3D.new()
	c.shape = s
	b.add_child(c)
	add_child(b)
