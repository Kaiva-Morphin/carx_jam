extends Interactible
class_name Inspectable


@onready var object = $Object
@onready var object_mesh : MeshInstance3D = $Object/Object
@onready var prop = $Prop
@export var child_hint : bool  = false

func _ready() -> void:
	add_to_group("interactible")
	if child_hint:
		need_hint_ = false
	super._ready()
	interaction_end.connect(GLOBAL.unblock_player)
	if object_mesh:
		object_mesh.layers = 2

var inspecting = false

func interact():
	GLOBAL.ui_state = GLOBAL.UI_STATE.INSPECTING
	inspecting = true
	super.interact()
	object.show()
	object.reparent(GLOBAL.inspect_node)
	object.position = Vector3(0.0, 0.0, 0.0)
	object.rotation = Vector3.ZERO
	GLOBAL.block_player()
	GLOBAL.processor.blur_in()
	GLOBAL.hints.hint("back", "KEY_INSPECT_BACK")


func end_interaction():
	inspecting = false
	GLOBAL.processor.blur_out()
	interaction_end.emit()
	object.hide()
	GLOBAL.ui_state = GLOBAL.UI_STATE.GAME
	GLOBAL.hints.rm_hint("back")


var sensitivity := 0.0005
var gamepad_multiplier := 5.0

var yaw := 0.0
var pitch := 0.0

var target_yaw := 0.0
var target_pitch := 0.0

var pitch_limit := deg_to_rad(50.0)

var velocity := Vector2.ZERO
var damping := 6.0

var smooth_speed := 10.0

var idle_rotate_speed := 0.0
var idle_threshold := 0.01


func _unhandled_input(event):
	if !inspecting:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		velocity = event.relative * sensitivity * 10.0 * Vector2(-1.0, 1.0)


func handle_gamepad():
	var look_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var look_y = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	var v = Vector2(look_x, look_y)
	if v.length() > 0.02:
		velocity = v * sensitivity * 10.0 * Vector2(-1.0, 1.0)


func _process(delta):
	if !inspecting:
		return
	handle_gamepad()
	if Input.is_action_just_pressed("back") || Input.is_action_just_pressed("open_tab"):
		end_interaction()

	target_yaw -= velocity.x
	target_pitch -= velocity.y

	target_pitch = clamp(target_pitch, -pitch_limit, pitch_limit)

	velocity = velocity.lerp(Vector2.ZERO, damping * delta)

	if velocity.length() < idle_threshold:
		target_yaw += idle_rotate_speed * delta

	yaw = lerp(yaw, target_yaw, smooth_speed * delta)
	pitch = lerp(pitch, target_pitch, smooth_speed * delta)

	object.rotation = Vector3(0.0, yaw, 0.0)
	GLOBAL.inspect_cam_joint.rotation.x = pitch
