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
	dbgs.append("STATE: " + STATES.keys()[state])
	dbgs.append("FPS: " + str(Engine.get_frames_per_second()))
	$CanvasLayer/Label.text = "\n".join(dbgs)
#endregion

enum STATES {
	STAND,
	WALK,
	RUN,
	CRUNCH,
	SLIDE,
	LOWJUMP,
	HIGHJUMP,
	ONWALL,
}
var state := STATES.STAND


@onready var player_camera_joint := $Joint
@onready var player_camera := $Joint/PlayerCamera
@onready var crunch_camera_target := $CrunchCamTarget
@onready var stand_camera_target := $StandCamTarget
@onready var stand_collider := $StandCollider
@onready var crunch_collider := $CrunchCollider
@onready var crunch_shapecast := $CrunchShapecast

var CAMERA_INTERPOLATION_SPEED := 20.0

var GRAVITY := 9.8
var JUMP_FORCE := 100.0
var CRUNCH_SPEED := 10.0
var WALK_SPEED := 20.0
var RUN_SPEED := 25.0
var STOP_SPEED := 10.0

var FOV := 75.0
var CRUNCH_FOV_ADD := -10.0
var WALK_FOV_ADD := 0.0
var RUN_FOV_ADD :=  15.0
var FOV_DT_SPEED := 5.0
var ROLL_DEG = 5.0
var PITCH_DEG = 4.0
var CRUNCH_ROLL_MOD = 0.3
var CRUNCH_PITCH_MOD = 0.4
var BOB_FREQ = 1.3
var BOB_AMP = 0.07
var t_bob = 0.0
var CRUNCH_BOB_AMP_MUL = 1.5
var CRUNCH_BOB_MUL = 0.5
var WALK_BOB_MUL = 1.0
var RUN_BOB_MUL = 2.0


func _ready() -> void:
	pass

var roll_vel := 0.0
var pitch_vel := 0.0


func smooth_damp(current: float, target: float, vel: float, smooth_time: float, dt: float) -> Vector2:
	var omega = 2.0 / smooth_time
	var x = omega * dt
	var exp_ = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var change = current - target
	var temp = (vel + omega * change) * dt
	var new_velocity = (vel - omega * temp) * exp_
	var output = target + (change + temp) * exp_
	return Vector2(output, new_velocity)

func ease_linear(t: float) -> float:
	return t

func ease_out_quad(t: float) -> float:
	return 1.0 - (1.0 - t) * (1.0 - t)

func ease_in_out_quad(t: float) -> float:
	return 2.0 * t * t if t < 0.5 else 1.0 - pow(-2.0 * t + 2.0, 2.0) / 2.0

func ease_out_cubic(t: float) -> float:
	return 1.0 - pow(1.0 - t, 3.0)

func ease_out_back(t: float) -> float:
	var c1 = 1.70158
	var c3 = c1 + 1.0
	return 1.0 + c3 * pow(t - 1.0, 3.0) + c1 * pow(t - 1.0, 2.0)

func ease_lerp_angle(current: float, target: float, speed: float, dt: float, ease_func: Callable) -> float:
	var t = 1.0 - exp(-speed * dt)
	t = clamp(t, 0.0, 1.0)
	t = ease_func.call(t)
	return lerp_angle(current, target, t)

func easeOutBack(x: float) -> float:
	const c1 = 1.70158;
	const c3 = c1 + 1;
	return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2);


func _process(dt: float) -> void:
	if Input.is_action_just_pressed("back"): Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	update_debug()
	
	
	var ax = Input.get_axis("left", "right")
	
	
	
	
	#region CAMERA
	var target_pitch = -ax * deg_to_rad(0.9)
	player_camera_joint.rotation.z = lerp_angle(player_camera_joint.rotation.z, target_pitch, dt * 5.0)
	#var target_roll = -input_dir.x * deg_to_rad(ROLL_DEG)
	#var target_pitch = min(0.0, -input_dir.y) * deg_to_rad(PITCH_DEG)
	#if states(STATES.CRUNCH):
		#target_roll *= CRUNCH_ROLL_MOD
		#target_pitch *= CRUNCH_PITCH_MOD
	#
	#var ease_roll = Callable(self, "easeOutBack")
	#var ease_pitch = Callable(self, "easeOutBack")
#
	#player_camera_joint.rotation.z = ease_lerp_angle(
		#player_camera_joint.rotation.z,
		#target_roll,
		#8.0,
		#dt,
		#ease_roll
	#)
#
	#player_camera_joint.rotation.x = ease_lerp_angle(
		#player_camera_joint.rotation.x,
		#target_pitch,
		#6.0,
		#dt,
		#ease_pitch
	#)
	
	if states(STATES.SLIDE, STATES.CRUNCH):
		player_camera_joint.position.y = lerp(player_camera_joint.position.y, crunch_camera_target.position.y, dt * CAMERA_INTERPOLATION_SPEED)
	else:
		player_camera_joint.position.y = lerp(player_camera_joint.position.y, stand_camera_target.position.y, dt * CAMERA_INTERPOLATION_SPEED)
	var cam_fov_target := FOV
	var fov_change = false
	if states(STATES.CRUNCH):
		cam_fov_target = FOV + CRUNCH_FOV_ADD
		fov_change = true
	if states(STATES.WALK):
		cam_fov_target = FOV + WALK_FOV_ADD
		fov_change = true
	if states(STATES.RUN):
		cam_fov_target = FOV + RUN_FOV_ADD
		fov_change = true
	if fov_change:
		player_camera.fov = lerp(player_camera.fov, cam_fov_target, dt * FOV_DT_SPEED)
	#endregion CAMERA
	
	handle_gamepad()
	# actions

	

func _physics_process(dt: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	match state:
		STATES.STAND:
			velocity.x = move_toward(velocity.x, 0.0, STOP_SPEED * dt)
			velocity.z = move_toward(velocity.z, 0.0, STOP_SPEED * dt)
		STATES.CRUNCH:
			velocity = direction * CRUNCH_SPEED
			if !Input.is_action_pressed("crunch") && !crunch_shapecast.is_colliding():
				state = STATES.STAND
				crunch_collider.disabled = true
				stand_collider.disabled = false
		STATES.WALK:
			velocity = direction * WALK_SPEED
			if !direction:
				state = STATES.STAND
		STATES.RUN:
			velocity = direction * RUN_SPEED
			if !Input.is_action_pressed("run") || !direction:
				state = STATES.STAND
		STATES.SLIDE:
			pass
	# gravity
	if !is_on_floor():
		velocity.y -= GRAVITY * dt  * 30
	# transitions
	if states(STATES.HIGHJUMP, STATES.LOWJUMP) && is_on_floor(): state = STATES.STAND
	if states(STATES.STAND, STATES.WALK, STATES.RUN) && Input.is_action_just_pressed("jump") && is_on_floor():
		state = STATES.HIGHJUMP
		velocity.y = 50
	if states(STATES.HIGHJUMP) && !Input.is_action_pressed("jump"):
		state = STATES.LOWJUMP
	
	if direction && states(STATES.STAND):
		state = STATES.WALK
	if Input.is_action_just_pressed("crunch") && states(STATES.STAND, STATES.WALK, STATES.RUN):
		state = STATES.CRUNCH
		crunch_collider.disabled = false
		stand_collider.disabled = true
	if Input.is_action_pressed("run") && states(STATES.WALK):
		state = STATES.RUN
	move_and_slide()


#region TOOLS

func head_bob(dt):
	var t_bob_n = 0.0
	if is_on_floor():
		t_bob_n = Vector2(velocity.x, velocity.z).length() * dt
	t_bob += t_bob_n
	var bob_amp = BOB_AMP
	if states(STATES.CRUNCH):
		bob_amp *= CRUNCH_BOB_AMP_MUL 
	player_camera.position.y = sin(t_bob * BOB_FREQ) * bob_amp


func states(...args):
	return state in args

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

var sensitivity := 0.003
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * sensitivity)
		var target = -event.relative.y * sensitivity
		if target > 0:
			if player_camera.global_rotation.x + target < 1.53:
				player_camera.rotate_x(target)
		else:
			if player_camera.global_rotation.x + target > -1.53:
				player_camera.rotate_x(target)
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#$"../Control/CenterContainer".show()
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		#if !$"../Control/CenterContainer".visible:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#endregion
