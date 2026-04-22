extends Node3D

@onready var cam = $CamJoint/Camera3D


# ─────────────────────────────────────────────
#  ATOM CLASS
# ─────────────────────────────────────────────
class Atom extends Area3D:
	var neighbors  : Array         = []   # Array[Atom] — forward-declared as plain Array
	var _enabled   : MeshInstance3D
	var _disabled  : MeshInstance3D
	var enabled    : bool = false
	var grid_pos   : Vector3i         # position in grid, used for animation

	func _init(col: CollisionShape3D, e: MeshInstance3D, d: MeshInstance3D) -> void:
		add_child(col.duplicate())
		_enabled  = e.duplicate()
		_disabled = d.duplicate()
		add_child(_enabled)
		add_child(_disabled)
		_enabled.position  = Vector3.ZERO
		_disabled.position = Vector3.ZERO
		enabled = true
		collision_mask = 16
		collision_layer = 16
		_apply_visual()

	func _apply_visual() -> void:
		if enabled:
			_enabled.show();  _disabled.hide()
		else:
			_disabled.show(); _enabled.hide()

	func swap(mouse= false) -> void:
		_unupdated_swap()
		if mouse:
			self.tween()
		for n in neighbors:
			n._unupdated_swap()
			if mouse:
				n.tween(0.8)
	
	func tween(s=1.0):
		var tw = create_tween()
		if self.enabled:
			tw.tween_property(self, "scale", s * Vector3.ONE * 1.5, 0.18) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tw.tween_property(self, "scale", Vector3.ONE, 0.18) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		else:
			tw.tween_property(self, "scale", s * Vector3.ONE * 1.5, 0.18) \
				.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
			tw.tween_property(self, "scale", Vector3.ONE, 0.18) \
				.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	func _unupdated_swap() -> void:
		enabled = !enabled
		_apply_visual()

const GRID_SIZE  := Vector3i(4, 3, 4)
const CELL_SIZE  := 2.0
var levels : Array = [
	#[[1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],
	#[[1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],
	[
		[1,1,0,0,
		 1,1,0,0,
		 0,0,0,0,
		 0,0,0,0],

		[0,0,0,0,
		 0,1,1,0,
		 0,1,1,0,
		 0,0,0,0],

		[0,0,0,0,
		 0,0,0,0,
		 0,0,1,1,
		 0,0,1,1]
	],

	[
		[0,0,0,0,
		 0,0,0,0,
		 0,0,0,0,
		 0,0,0,0],

		[0,1,1,0,
		 1,1,1,1,
		 0,1,1,0,
		 0,0,0,0],

		[0,0,0,0,
		 0,1,1,0,
		 0,0,0,0,
		 0,0,0,0]
	],

	[
		[0,0,0,0,
		 0,1,0,0,
		 0,1,0,0,
		 0,0,0,0],

		[0,1,1,1,
		 1,1,0,0,
		 0,1,0,0,
		 0,0,0,0],

		[0,0,0,0,
		 0,1,1,0,
		 0,1,0,0,
		 0,1,0,0]
	],

	[
		[1,1,1,1,
		 1,0,0,1,
		 1,0,0,1,
		 1,1,1,1],

		[1,0,0,1,
		 0,0,0,0,
		 0,0,0,0,
		 1,0,0,1],

		[1,1,1,1,
		 1,0,0,1,
		 1,0,0,1,
		 1,1,1,1]
	],
]

# ─────────────────────────────────────────────
#  STATE
# ─────────────────────────────────────────────
var current_level : int  = 0
var grid          : Dictionary = {}
var atoms         : Array      = []   # all Atom nodes
var field         : Array      = []   # same as atoms (used for win check)
var connections   : Array      = []   # MeshInstance3D cylinders
var is_animating  : bool       = false

var is_dragging := false
var drag_started := false
var drag_start_pos := Vector2.ZERO

# --- CAMERA ROTATION VARIABLES (Modified from Inspectable) ---
var _rotate_y := 0.0       # Current Yaw
var _rotate_x := 0.0       # Current Pitch

var target_rotate_y := 0.0 # Target Yaw
var target_rotate_x := 0.0 # Target Pitch

var drag_sensitivity := 0.01
var smooth_speed := 10.0   # Speed of lerp smoothing
var pitch_limit := deg_to_rad(25.0)
var pitch_limit_top := deg_to_rad(25.0)
# -----------------------------------------------------------

var scene_root : Node3D



# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	virtual_cursor.hide()
	$Sample.hide()
	$Sample.process_mode = PROCESS_MODE_DISABLED
	VOICEOVER.sequence_end.connect(on_seq_end)
	$DirectionalLight3D.show()

# ─────────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────────
var total = 0.0
func _input(event: InputEvent) -> void:
	if GLOBAL.ui_state != GLOBAL.UI_STATE.ATOM: return
	if event is InputEventMouseButton:
		if event.pressed:
			total = 0.0
			is_dragging = true
			drag_started = false
			drag_start_pos = event.position
		else:
			if not drag_started:
				_raycast_from_screen(event.position)
			is_dragging = false
			
	elif event is InputEventMouseMotion and is_dragging:
		var delta = event.relative
		total += delta.length()
		if not drag_started and event.relative.length() > 1.5 || total > 3.0:
			drag_started = true
		
		if drag_started:
			# Изменяем целевые углы, а не текущие напрямую
			target_rotate_y += delta.x * drag_sensitivity
			target_rotate_x += delta.y * drag_sensitivity # Инверсия оси Y обычно нужна, но зависит от настройки управления
			
			# Ограничиваем цель по вертикали сразу при вводе
			target_rotate_x = clamp(target_rotate_x, -pitch_limit, pitch_limit_top)


@onready var virtual_cursor : Control = $CanvasLayer/Control/Control
@onready var virtual_cursor_texture : TextureRect = $CanvasLayer/Control/Control/Texture
var virtual_cursor_pos : Vector2 = Vector2.ZERO
var virtual_cursor_sensivity : float = 0.5

var hovered = false
var pressed = false
var gamepad_sensitivity = 0.015
func handle_gamepad():
	if !GLOBAL.hints.is_gamepad: return
	var look_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var look_y = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	var v = Vector2(look_x, look_y)
	if v.length() > 0.02:
		v = v * gamepad_sensitivity * Vector2(-1.0, -1.0)
		target_rotate_x += v.y
		target_rotate_y += v.x * 0.1
		target_rotate_x = clamp(target_rotate_x, -pitch_limit, pitch_limit_top)
	var x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	virtual_cursor.position += Vector2(x, y) * virtual_cursor_sensivity
	var c = _gamepad_raycast_from_screen(virtual_cursor.global_position)
	pressed = Input.is_action_pressed("lab_swap")
	if c:
		if Input.is_action_just_pressed("lab_swap"):
			c.swap(true)
			if check_win():
				_trigger_win()
		hovered = true
	else:
		hovered = false
	_limit_cursor_to_screen()

func _limit_cursor_to_screen() -> void:
	var vp_size = get_viewport().size
	# position у Control локальный, поэтому ограничиваем относительно родителя
	# Если родитель - корневой Control/CanvasLayer, это сработает корректно
	virtual_cursor.position.x = clampf(virtual_cursor.position.x, 0, vp_size.x)
	virtual_cursor.position.y = clampf(virtual_cursor.position.y, 0, vp_size.y)

func _gamepad_raycast_from_screen(screen_pos: Vector2) -> Node3D:
	var camera := get_viewport().get_camera_3d()
	var from   := camera.project_ray_origin(screen_pos)
	var dir    := camera.project_ray_normal(screen_pos)
	var to     := from + dir * 1000.0
	var space  := get_world_3d().direct_space_state
	var query  := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 16
	query.collide_with_areas = true
	var result := space.intersect_ray(query)
	return result.collider if result else null
	#if result:
		#result.collider.swap(true)
		#if check_win():
			#_trigger_win()

signal end

var dialog_ready = false
var level_solved = false
func begin():
	virtual_cursor.position = $CanvasLayer/Control.size * 0.5
	GLOBAL.hints.hint("dialog_next", "KEY_DIALOG_NEXT")
	GLOBAL.hints.hint("lab_swap", "KEY_LAB_SWAP")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	cam.current = true
	virtual_cursor.show()
	load_level(0)
	await _animate_enter()
	is_animating = false
	VOICEOVER.auto_next = true
	VOICEOVER.start_sequence(sequences[0])

var sequences = ["lab_1", "lab_2", "lab_3", "lab_4", "lab_5"]

func on_seq_end(seq):
	if seq in sequences:
		dialog_ready = true
		check_next()

func on_next():
	dialog_ready = false
	if current_level == levels.size() + 1:
		GLOBAL.hints.rm_hint("dialog_next")
		GLOBAL.hints.rm_hint("lab_swap")
		virtual_cursor.hide()
		end.emit()
		return
	await get_tree().create_timer(0.5).timeout
	VOICEOVER.auto_next = true
	VOICEOVER.start_sequence(sequences[current_level])
	if current_level == levels.size():
		current_level += 1
		dialog_ready = false
		return
	dialog_ready = false
	level_solved = false
	load_level(current_level)
	await _animate_enter()
	is_animating = false

func check_next():
	if dialog_ready && level_solved:
		on_next()

func _raycast_from_screen(screen_pos: Vector2) -> void:
	var camera := get_viewport().get_camera_3d()
	var from   := camera.project_ray_origin(screen_pos)
	var dir    := camera.project_ray_normal(screen_pos)
	var to     := from + dir * 1000.0
	var space  := get_world_3d().direct_space_state
	var query  := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 16
	query.collide_with_areas = true
	var result := space.intersect_ray(query)
	if result:
		result.collider.swap(true)
		if check_win():
			_trigger_win()

# ─────────────────────────────────────────────
#  WIN CHECK
# ─────────────────────────────────────────────
func check_win() -> bool:
	for atom in field:
		if not atom.enabled:
			return false
	return true

func _process(delta: float) -> void:
	if !GLOBAL.hints.is_gamepad:
		virtual_cursor.position = lerp(virtual_cursor.position, $CanvasLayer/Control.size * 0.5, delta * 10.0)
		virtual_cursor_texture.modulate.a = lerp(virtual_cursor_texture.modulate.a, 0.0, delta * 10.0)
	else:
		var scale_factor = 1.0
		if hovered:
			scale_factor += 0.5
			virtual_cursor_texture.modulate.a = lerp(virtual_cursor_texture.modulate.a, 0.9, delta * 10.0)
		else:
			virtual_cursor_texture.modulate.a = lerp(virtual_cursor_texture.modulate.a, 0.4, delta * 10.0)
		if pressed:
			scale_factor -= 0.5
		virtual_cursor_texture.scale = lerp(virtual_cursor_texture.scale, Vector2.ONE * scale_factor, delta * 10.0)
	
	# Если мы не тащим мышку, вертикальный угол стремится к 0
	if GLOBAL.ui_state != GLOBAL.UI_STATE.ATOM: return
	handle_gamepad()
	target_rotate_x = lerp(target_rotate_x, 0.0, smooth_speed * delta)
	
	# Плавное приближение текущих углов к целевым (Lerp)
	_rotate_y = lerp(_rotate_y, target_rotate_y, smooth_speed * delta)
	_rotate_x = lerp(_rotate_x, target_rotate_x, smooth_speed * delta)
	
	# Применяем вращение к сцене
	if scene_root:
		scene_root.rotation.y = _rotate_y
		$CamJoint.rotation.x = _rotate_x
	# -----------------------------

func _trigger_win() -> void:
	is_animating = true
	await _animate_win()
	current_level = (current_level + 1)
	await _animate_exit()
	_clear_field()
	level_solved = true
	check_next()


# ─────────────────────────────────────────────
#  LEVEL LOADING
# ─────────────────────────────────────────────
func load_level(index: int) -> void:
	scene_root = Node3D.new()
	add_child(scene_root)
	var level_data : Array = levels[index]
	grid  = {}
	atoms = []
	field = []

	var col_src  : CollisionShape3D = $Sample/Col   as CollisionShape3D
	var en_src   : MeshInstance3D   = $Sample/En    as MeshInstance3D
	var dis_src  : MeshInstance3D   = $Sample/Dis   as MeshInstance3D

	# 1. Spawn atoms
	for y in range(GRID_SIZE.y):
		var layer : Array = level_data[y]
		for z in range(GRID_SIZE.z):
			for x in range(GRID_SIZE.x):
				var flat_idx : int = z * GRID_SIZE.x + x
				if layer[flat_idx] == 0:
					continue
				var gpos := Vector3i(x, y, z)
				var atom := Atom.new(col_src, en_src, dis_src)
				atom.grid_pos = gpos
				atom.position = Vector3(x, y, z) * CELL_SIZE
				scene_root.add_child(atom)
				grid[gpos] = atom
				atoms.append(atom)
				field.append(atom)

	# 2. Connect neighbors (axis-aligned only, no diagonals)
	var dirs := [
		Vector3i(1,0,0), Vector3i(-1,0,0),
		Vector3i(0,1,0), Vector3i(0,-1,0),
		Vector3i(0,0,1), Vector3i(0,0,-1),
	]
	for atom in atoms:
		for d in dirs:
			var nb_pos = atom.grid_pos + d
			if grid.has(nb_pos):
				var nb : Atom = grid[nb_pos]
				if not atom.neighbors.has(nb):
					atom.neighbors.append(nb)

	# 3. Draw connection meshes
	for atom in atoms:
		for nb in atom.neighbors:
			if atom.get_index() < nb.get_index():
				var c = _make_connection(atom.position, nb.position)
				connections.append(c)
				scene_root.add_child(c)
	# 4. Randomise start state (so puzzle isn't trivially solved)
	_randomise_start()
	_center_scene()

func _center_scene() -> void:
	if atoms.is_empty():
		return
	
	var centre := Vector3.ZERO
	for atom in atoms:
		centre += atom.position
	centre /= atoms.size()
	for atom in atoms:
		atom.position -= centre
	for conn in connections:
		conn.position -= centre

func _randomise_start() -> void:
	randomize()
	# Make 5-15 random swaps; this guarantees a solvable (but scrambled) state
	var moves := randi_range(7, 25)
	for _i in range(moves):
		var atom : Atom = atoms[randi() % atoms.size()]
		atom.swap()

# ─────────────────────────────────────────────
#  CONNECTION CYLINDER
# ─────────────────────────────────────────────
func _make_connection(from: Vector3, to: Vector3) -> MeshInstance3D:
	var c : MeshInstance3D = $Sample/Conn.duplicate() as MeshInstance3D
	#add_child(c)
	var dir    := to - from
	var length := dir.length()
	dir = dir.normalized()
	c.position   = (from + to) / 2.0
	c.mesh       = c.mesh.duplicate()        # own copy so height is independent
	(c.mesh as CylinderMesh).height = length
	var up      := dir
	var right   := up.cross(Vector3.FORWARD).normalized()
	if right.length() < 0.001:
		right = up.cross(Vector3.RIGHT).normalized()
	var forward := right.cross(up)
	c.transform.basis = Basis(right, up, forward)
	return c

# ─────────────────────────────────────────────
#  FIELD CLEANUP
# ─────────────────────────────────────────────
func _clear_field() -> void:
	for atom in atoms:
		atom.queue_free()
	for conn in connections:
		conn.queue_free()
	atoms       = []
	field       = []
	connections = []
	grid        = {}

# ─────────────────────────────────────────────
#  ANIMATIONS
# ─────────────────────────────────────────────

# Win celebration: atoms pulse scale up/down twice, then a rainbow colour flash
func _animate_win() -> Signal:
	var tween := create_tween().set_parallel(true)
	for atom in atoms:
		tween.tween_property(atom, "scale", Vector3.ONE * 1.5, 0.18) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
	var tween2 := create_tween().set_parallel(true)
	for atom in atoms:
		tween2.tween_property(atom, "scale", Vector3.ONE, 0.18) \
			.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	await tween2.finished
	return tween2.finished   # dummy, just so we can "await _animate_win()"

# Exit: atoms fly outward from center and fade (scale to 0)
func _animate_exit() -> void:
	if atoms.is_empty():
		return
	# Compute centroid
	var centre := Vector3.ZERO
	for atom in atoms:
		centre += atom.position
	centre /= atoms.size()

	var tween := create_tween().set_parallel(true)
	for atom in atoms:
		var dir = (atom.position - centre).normalized()
		if dir.length_squared() < 0.001:
			dir = Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1)).normalized()
		var target = atom.position + dir * 8.0
		tween.tween_property(atom, "position", target, 0.45) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(atom, "scale", Vector3.ZERO, 0.45) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	# Connections fade out together
	for conn in connections:
		tween.tween_property(conn, "scale", Vector3.ZERO, 0.3) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished

# Enter: atoms fly in from random scatter positions, scale 0 → 1
func _animate_enter() -> void:
	if atoms.is_empty():
		return
	var centre := Vector3.ZERO
	for atom in atoms:
		centre += atom.position
	centre /= atoms.size()

	# Teleport atoms far away, scale zero, then tween to real position
	for atom in atoms:
		var dir = (atom.position - centre).normalized()
		if dir.length_squared() < 0.001:
			dir = Vector3(randf_range(-1,1), randf_range(-1,1), randf_range(-1,1)).normalized()
		var start_pos = atom.position + dir * 10.0
		var real_pos  = atom.position
		atom.position = start_pos
		atom.scale    = Vector3.ZERO
		# Store real position for tween
		atom.set_meta("_real_pos", real_pos)

	# Stagger each atom slightly
	var tween := create_tween().set_parallel(true)
	for i in range(atoms.size()):
		var atom : Atom = atoms[i]
		var delay := i * 0.03
		tween.tween_property(atom, "position", atom.get_meta("_real_pos"), 0.5) \
			.set_delay(delay) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(atom, "scale", Vector3.ONE, 0.5) \
			.set_delay(delay) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Connections pop in at the end
	for conn in connections:
		conn.scale = Vector3.ZERO
		tween.tween_property(conn, "scale", Vector3.ONE, 0.3) \
			.set_delay(atoms.size() * 0.03 + 0.1) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished
