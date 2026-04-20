extends Interactable
class_name Inspectable


@onready var object = $Object
@onready var object_mesh : MeshInstance3D = $Object/Object
@onready var prop = $Prop


func _ready() -> void:
	add_to_group("interactible")
	super._ready()
	interaction_end.connect(GLOBAL.unblock_player)
	object_mesh.layers = 2

func hint() -> String:
	return "E - inspect"
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

func end_interaction():
	inspecting = false
	GLOBAL.processor.blur_out()
	interaction_end.emit()
	object.hide()
	GLOBAL.ui_state = GLOBAL.UI_STATE.GAME

var sensitivity := 0.0005
var gamepad_multiplier := 5.0

var yaw := 0.0
var pitch := 0.0

var target_yaw := 0.0
var target_pitch := 0.0

# ограничения
var pitch_limit := 1.53

# инерция
var velocity := Vector2.ZERO
var damping := 6.0

# сглаживание
var smooth_speed := 10.0

# авто-вращение
var idle_rotate_speed := 0.3
var idle_threshold := 0.001

func _unhandled_input(event):
	if !inspecting:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		velocity = event.relative * sensitivity * 10.0 * Vector2(-1.0, 1.0)

func _process(delta):
	if !inspecting:
		return
	if Input.is_action_just_pressed("back") || Input.is_action_just_pressed("open_tab"):
		end_interaction()

	_handle_gamepad(delta)
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

func _handle_gamepad(delta):
	var look_x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var look_y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")

	if abs(look_x) > 0.01 or abs(look_y) > 0.01:
		target_yaw -= look_x * sensitivity * gamepad_multiplier * 60.0 * delta
		target_pitch -= look_y * sensitivity * gamepad_multiplier * 60.0 * delta
