extends Node3D


class Atom extends Area3D:
	var neighbors : Array[Atom] = []
	var _enabled : MeshInstance3D
	var _disabled : MeshInstance3D
	var enabled = false
	
	func _init(c, e, d):
		add_child(c.duplicate())
		_enabled = e.duplicate()
		_disabled = d.duplicate()
		add_child(_enabled)
		_enabled.position = Vector3.ZERO
		add_child(_disabled)
		_disabled.position = Vector3.ZERO
		enabled = true
		swap()
	
	func swap():
		unupdated_swap()
		for n in neighbors:
			n.unupdated_swap()
	func unupdated_swap():
		enabled = !enabled
		if enabled:
			_enabled.show()
			_disabled.hide()
		else:
			_disabled.show()
			_enabled.hide()
func check_win():
	for atom in field:
		if !atom.enabled: return false
	print("WIN")
	return true


var field : Array[Atom]


func make_connection(from : Vector3, to: Vector3):
	var c = $Sample/Conn.duplicate() # cyl
	add_child(c)
	c.position = (from + to) / 2.0
	# ALIGN
	var dir = (to - from).normalized()
	var b = Basis()
	b.y = dir
	b.x = dir.cross(Vector3.FORWARD).normalized()
	b.z = b.x.cross(b.y).normalized()
	c.transform.basis = b


func _ready() -> void:
	# init grid
	var offset = Vector3(2.0, 0, 0)
	var start = Vector3(-4, 0, 0)
	var prev = start
	var atoms : Array[Atom] = []
	for i in range(6):
		var pos = start + offset * i
		make_connection(prev, pos)
		prev = pos
		var a = Atom.new($Sample/CollisionShape3D, $Sample/Enabled, $Sample/Disabled)
		add_child(a)
		a.position = start + offset * i + offset * 0.5
		atoms.append(a)
	for a in range(len(atoms)):
		if a == 0:
			atoms[a].neighbors = [atoms[a+1]]
		elif a == len(atoms) - 1:
			atoms[a].neighbors = [atoms[a-1]]
		else:
			atoms[a].neighbors = [atoms[a-1], atoms[a+1]]
	$Sample.hide()
	$Sample.process_mode = PROCESS_MODE_DISABLED



func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		raycast_from_screen(event.position)


func raycast_from_screen(screen_pos: Vector2):
	var camera = get_viewport().get_camera_3d()
	
	var from = camera.project_ray_origin(screen_pos)
	var dir = camera.project_ray_normal(screen_pos)
	var to = from + dir * 1000.0  # длина луча
	
	var space = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	
	var result = space.intersect_ray(query)
	
	if result:
		print("Попал в:", result.collider)
		print("Точка:", result.position)
		result.collider.swap()
		check_win()
