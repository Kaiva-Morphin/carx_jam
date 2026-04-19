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
		result.collider.swap()
		check_win()


const GRID_SIZE := Vector3i(4, 2, 4)

const MIN_NEIGHBORS := 2
const MAX_NEIGHBORS := 4

const CELL_SIZE := 2.0

var grid := {} # Vector3i -> Atom
var atoms := []
var field := []

func _ready() -> void:
	generate_grid()
	$Sample.hide()
	$Sample.process_mode = PROCESS_MODE_DISABLED
	
func generate_grid():
	var origin = Vector3(-GRID_SIZE.x, 0, -GRID_SIZE.z) * CELL_SIZE
	
	# 1. создаём узлы (не все заполняем)
	for x in GRID_SIZE.x:
		for y in GRID_SIZE.y:
			for z in GRID_SIZE.z:
				if randf() < 0.7: # плотность
					var a = Atom.new(
						$Sample/CollisionShape3D,
						$Sample/Enabled,
						$Sample/Disabled
					)
					
					var pos = origin + Vector3(x, y, z) * CELL_SIZE
					a.position = pos
					
					add_child(a)
					
					var key = Vector3i(x, y, z)
					grid[key] = a
					atoms.append(a)
					field.append(a)
	
	# 2. создаём связи
	for key in grid.keys():
		var a = grid[key]
		var neighbors := get_neighbors(key)
		
		for nkey in neighbors:
			var b = grid.get(nkey)
			if b and not a.neighbors.has(b):
				a.neighbors.append(b)
				b.neighbors.append(a)
				
				make_connection(a.position, b.position)
	
	# 3. балансируем степени
	balance_graph()


func get_neighbors(p: Vector3i) -> Array:
	return [
		p + Vector3i(1, 0, 0),
		p + Vector3i(-1, 0, 0),
		p + Vector3i(0, 1, 0),
		p + Vector3i(0, -1, 0),
		p + Vector3i(0, 0, 1),
		p + Vector3i(0, 0, -1),
	].filter(func(v):
		return grid.has(v)
	)

func balance_graph():
	for a in atoms:
		while a.neighbors.size() > MAX_NEIGHBORS:
			var n = a.neighbors.pick_random()
			a.neighbors.erase(n)
			n.neighbors.erase(a)
		
	for a in atoms:
		if a.neighbors.size() < MIN_NEIGHBORS:
			var candidates = get_close_candidates(a)
			if candidates.size() > 0:
				var n = candidates.pick_random()
				a.neighbors.append(n)
				n.neighbors.append(a)
				make_connection(a.position, n.position)
				

func get_close_candidates(a: Atom) -> Array:
	var result := []
	for b in atoms:
		if b == a:
			continue
		if a.neighbors.has(b):
			continue
		if b.neighbors.size() >= MAX_NEIGHBORS:
			continue
		
		if a.position.distance_to(b.position) <= CELL_SIZE * 1.1:
			result.append(b)
	return result


func make_connection(from: Vector3, to: Vector3):
	var c = $Sample/Conn.duplicate()
	add_child(c)
	
	c.position = (from + to) / 2.0
	
	var dir = (to - from).normalized()
	var up = Vector3.RIGHT if abs(dir.dot(Vector3.UP)) > 0.99 else Vector3.UP
	
	c.look_at(to, up)
	c.rotate_x(deg_to_rad(90))
