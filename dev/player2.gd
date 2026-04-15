extends CharacterBody3D

#region DEBUG

var debug = {}

func dbg(key, value):
	debug[key] = value

func update_debug():
	var dbgs = []
	var keys = debug.keys()
	keys.sort()
	for key in keys:
		dbgs.append(key+" "+str(debug[key]))
	$CanvasLayer/Label.text = "\n".join(dbgs)

#endregion

enum STATES {STAND, WALK, RUN, INAIR, FALLING, CRUNCH, SLIDING, ONWALL, } 

#region CONSTS
var ACC_INAIR := 60.0
var INAIR_SPEED := 20.0
var INAIR_DOT_FACTOR := 2.0
var ACC_SPEED := 50.0
var DEC_SPEED := 0.16
var REDIR_AIR := 1.0
var SLIDE_SPEED := ACC_SPEED * 1.3
var JUMP_VELOCITY := 30
var MAX_AIRJUMPS := 1
var CAMERA_INTERPOLATION_SPEED := 20.0
var RUN_SPEED := 20.0
var GRAVITY : float = ProjectSettings.get_setting("physics/3d/default_gravity")  * 2.5
var MAX_SLOPE_ANGLE := deg_to_rad(45.0)
var MAX_COYOT_TIME = 0.1
var JUMP_STRENGTH = 12.0
var JUMP_BUFFER_TIME = 0.15
@export var TILT_STRENGTH := 0.05
@export var TILT_WALL_STRENGTH := 0.5
@export var tilt_limit := 10.0 

@onready var player_camera_joint := $Joint
@onready var player_camera := $Joint/PlayerCamera
@onready var crunch_camera_target := $CrunchCamTarget
@onready var stand_camera_target := $StandCamTarget
@onready var stand_collider := $StandCollider
@onready var crunch_collider := $CrunchCollider
@onready var crunch_shapecast := $CrunchShapecast

@onready var camera : Camera3D = $Joint/PlayerCamera

var jump_buffer = 0.0

var processing_return = false
func return_to_checkpoint():
	if locked: return
	if processing_return: return
	processing_return = true

func finish_return():
	processing_return = false
	velocity = Vector3.ZERO
	state = states.STAND
	self.rotation = c_rot
	global_position = checkpoint
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	await get_tree().process_frame
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON


var checkpoint
var c_rot
func _ready() -> void:
	checkpoint = global_position
	c_rot = self.rotation
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_dt: float) -> void:
	dbg("FPS", Engine.get_frames_per_second())
	if Input.is_action_just_pressed("back"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			$"../Control/CenterContainer".hide()
		else:
			$"../Control/CenterContainer".show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if state == STATES.SLIDING:
		camera.position.y = lerp(camera.position.y, crunch_camera_target.position.y, _dt * CAMERA_INTERPOLATION_SPEED)
	else:
		camera.position.y = lerp(camera.position.y, stand_camera_target.position.y, _dt * CAMERA_INTERPOLATION_SPEED)
	if locked: return
	if global_position.y < -75.0:
		return_to_checkpoint()
	if !velocity.is_finite() || !global_position.is_finite():
		return_to_checkpoint()
	if Input.is_action_just_pressed("return"):
		return_to_checkpoint()
		return
	update_debug()
	var speed = velocity.length()
	camera.fov = clamp(lerp(camera.fov, 95.0 + 0.5 * speed, _dt * 20.0), 10, 170)


func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#$"../Control/CenterContainer".show()
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		#if !$"../Control/CenterContainer".visible:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	return

#endregion




var inair_jumps := MAX_AIRJUMPS
var input_dir := Vector2.ZERO

var prev_camera_rotation := Vector3.INF

var state : STATES = STATES.STAND
var states = STATES

var coyot_time = 0.0

var locked = false




var wall_normal : = Vector3.ZERO
func _physics_process(_dt: float) -> void:
	if locked: return
	if Input.is_action_just_pressed("jump"):
		jump_buffer = JUMP_BUFFER_TIME
	else:
		jump_buffer = max(jump_buffer - _dt, 0.0)
	
	#if inair_jumps > 0:
		#$CenterContainer/Control/DJ.show()
	#else:
		#$CenterContainer/Control/DJ.hide()
	
	
	if is_on_floor():
		coyot_time = 0.0
	else:
		coyot_time += _dt
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var current_rotation = camera.rotation_degrees
	if wall_normal && !is_on_floor():
		var forward = -camera.global_transform.basis.z
		var normal = wall_normal.normalized()
		var side = forward.cross(normal).y
		var facing = 1.0 - abs(forward.dot(normal))
		var target_tilt = tilt_limit * side * facing
		current_rotation.z = lerp(
			current_rotation.z,
			target_tilt,
			TILT_WALL_STRENGTH
		)
	elif input_dir:
		var target_tilt = tilt_limit * -input_dir.x
		current_rotation.z = lerp(current_rotation.z, target_tilt, TILT_STRENGTH)
	else:
		current_rotation.z = lerp(
			current_rotation.z,
			0.0,
			TILT_STRENGTH
		)
		
	camera.rotation_degrees = current_rotation
	var floor_normal := Vector3.UP
	if is_on_floor():
		floor_normal = get_floor_normal()
		inair_jumps = MAX_AIRJUMPS
	if direction != Vector3.ZERO:
		direction = direction.slide(floor_normal).normalized()
	match state:
		states.STAND:
			if not is_on_floor():
				velocity.y -= GRAVITY * _dt
				state = states.INAIR
				return
			else:
				if velocity.length_squared() > 0.05:
					velocity = velocity.lerp(Vector3.ZERO, DEC_SPEED)
				else:
					velocity = Vector3.ZERO
			if direction.length_squared() > 0.01:
				state = states.MOVING
		states.MOVING:
			if not is_on_floor():
				velocity.y -= GRAVITY * _dt
				state = states.INAIR
				return
			if direction.length_squared() > 0.01:
				velocity = velocity.move_toward(direction * RUN_SPEED, _dt * ACC_SPEED)
			else:
				state = states.STAND
		states.INAIR:
			velocity.y -= GRAVITY * _dt
			if direction:
				var d = 1.0 - Vector2(direction.x, direction.z).normalized().dot(Vector2(velocity.x, velocity.z).normalized()) * 0.5 - 0.45
				d += 1.0 - clamp(velocity.length(), 0.0, 18.0) / 18.0
				d = clamp(d, 0.0, 1.0)
				velocity += _dt * ACC_INAIR * direction * d
			
			if velocity.y < 0.0 && wall_normal:
				velocity.y += GRAVITY * _dt * 0.7
			if is_on_floor():
				state = states.STAND
		states.SLIDING: pass
		states.DASH: pass
		states.ONWALL: pass
	handle_jump()
	move_and_slide()

func handle_jump():
	wall_normal = Vector3.ZERO
	var target = Vector3.ZERO
	var phys = PhysicsServer3D.space_get_direct_state(get_world_3d().space)
	for i in range(0, 360, 30):
		var ray = PhysicsRayQueryParameters3D.create(
			global_position, 
			global_position + Vector3(1, 0.5, 0).rotated(Vector3(0, 1, 0), deg_to_rad(i)), 1)
		var ray_coll = phys.intersect_ray(ray)
		if 'collider' in ray_coll.keys():
			target += ray_coll['normal']
	
	target = target.normalized()
	wall_normal = target
	if jump_buffer > 0.0:
		if target && !is_on_floor():
			velocity.y = JUMP_STRENGTH
			velocity += target * 15
			state = states.INAIR
			jump_buffer = 0.0
			inair_jumps = MAX_AIRJUMPS
			return

		# coyote jump
		elif coyot_time < MAX_COYOT_TIME:
			velocity.y = JUMP_STRENGTH
			jump_buffer = 0.0
			return

		# air jump
		elif inair_jumps > 0 and !is_on_floor():
			inair_jumps -= 1
			velocity.y = JUMP_STRENGTH
			jump_buffer = 0.0

var sensitivity := 0.005
func _unhandled_input(event):
	if locked: return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensitivity)
		var target = -event.relative.y * sensitivity
		if target > 0:
			if camera.global_rotation.x + target < 1.53:
				camera.rotate_x(target)
		else:
			if camera.global_rotation.x + target > -1.53:
				camera.rotate_x(target)
	if event is InputEventMouseButton:
		#if !$"../Control/CenterContainer".visible:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func handle_gamepad():
	var look_x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var look_y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	rotate_y(-look_x * sensitivity * 5)
	var target = -look_y * sensitivity * 5
	if target > 0:
		if player_camera_joint.global_rotation.x + target < 1.53:
			player_camera_joint.rotate_x(target)
	else:
		if player_camera_joint.global_rotation.x + target > -1.53:
			player_camera_joint.rotate_x(target)

func set_mouse_sensitivity(value: float):
	sensitivity = value

func _on_continue_pressed() -> void:
	$"../Control/CenterContainer".hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
