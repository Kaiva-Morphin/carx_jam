extends Node3D


var ui_target_size
func _ready():
	get_viewport().size_changed.connect(_on_size_changed)
	var size = DisplayServer.window_get_size()
	ui_target_size = size
	set_subviewport_size(size)
	GLOBAL.processor = self
	GLOBAL.dbg_label = $"../CanvasLayer/Dbg"


func _on_size_changed():
	var size = DisplayServer.window_get_size()
	set_subviewport_size(size)


var inv_ui_scale = 1.0
@onready var sc = $"../CanvasLayer/CinematicLines"
@onready var svc = $"../CanvasLayer/SubViewportContainer"
@onready var svc2 = $"../CanvasLayer/Board/SubViewportContainer"
func set_subviewport_size(size: Vector2):
	var rs = sc.size
	inv_ui_scale = ui_target_size.x / size.x
	var ui_inv_scale2 = ui_target_size.y / size.y
	# это пиздец
	if rs.x > ui_target_size.x :
		svc.scale = Vector2(ui_inv_scale2, ui_inv_scale2)
		svc.position = Vector2(0.0, 0.0)
	else:
		svc.scale = Vector2(inv_ui_scale, inv_ui_scale)
		svc.position = Vector2(0.0, -size.y * 0.5 * inv_ui_scale + ui_target_size.y * 0.5)
	$"../CanvasLayer/SubViewportContainer/SubViewport".size = size
	$"../CanvasLayer/Board/SubViewportContainer/SubViewport".size = size
	svc2.scale = svc.scale

func _unhandled_input(event):
	if event is InputEventMouseButton \
		&& (GLOBAL.ui_state == GLOBAL.UI_STATE.GAME \
		|| GLOBAL.ui_state == GLOBAL.UI_STATE.INSPECTING \
		|| GLOBAL.ui_state == GLOBAL.UI_STATE.DIALOG
		):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

var rotation_speed = 3.0
var current_yaw: float = 0.0
var current_pitch: float = 0.0
func _process(_dt: float) -> void:
	GLOBAL.GameAct
	if look_target:
		var cam = GLOBAL.player.camera
		var diff = cam.global_position - look_target.global_position
		
		# Целевые углы считаем напрямую, без промежуточного вектора
		var target_yaw = atan2(diff.x, diff.z)
		var target_pitch = -atan2(diff.y, Vector2(diff.x, diff.z).length())
		target_pitch = clamp(target_pitch, -1.53, 1.53)
		
		var t = 1.0 - exp(-rotation_speed * _dt)
		
		# Интерполируем углы, а не вектор — нет рывков при смене цели
		current_yaw = lerp_angle(current_yaw, target_yaw, t)
		current_pitch = lerp_angle(current_pitch, target_pitch, t)
		
		GLOBAL.player.global_rotation.y = current_yaw
		GLOBAL.player.camera.rotation.x = current_pitch
	else:
		# Сохраняем текущие углы, чтобы при следующем look_target не было рывка
		current_yaw = GLOBAL.player.global_rotation.y
		current_pitch = GLOBAL.player.camera.rotation.x
	if Input.is_action_just_pressed("unfocus"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("peek_hint") && GLOBAL.ui_state == GLOBAL.UI_STATE.GAME:
		for node in get_tree().get_nodes_in_group("visual_hint"): node.show()
	if Input.is_action_just_released("peek_hint"):
		for node in get_tree().get_nodes_in_group("visual_hint"): node.hide()
	if Input.is_action_just_pressed("open_tab"):
		if GLOBAL.ui_state == GLOBAL.UI_STATE.GAME:
			GLOBAL.ui_state = GLOBAL.UI_STATE.BOARD
			blur_in()
			board2d.fake_reset()
			board.show()
			# board.process_mode = Node.PROCESS_MODE_INHERIT
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			GLOBAL.block_player()
		elif GLOBAL.ui_state == GLOBAL.UI_STATE.BOARD:
			GLOBAL.ui_state = GLOBAL.UI_STATE.GAME
			close_tab()
	if Input.is_action_just_pressed("back") && GLOBAL.ui_state == GLOBAL.UI_STATE.BOARD:
		close_tab()
	
	GLOBAL.hint_node.hide()
	if GLOBAL.ui_state == GLOBAL.UI_STATE.GAME && GLOBAL.interaction_ray:
		var c = GLOBAL.interaction_ray.get_collider()
		if c && c.is_in_group("interactible"):
			GLOBAL.hint_node.show()
			GLOBAL.hint_node.text = c.hint()
			if Input.is_action_just_pressed("interact"):
				c.interact()


func close_tab():
	blur_out()
	board.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GLOBAL.unblock_player()


@onready var board = $"../CanvasLayer/Board"
@onready var board2d = $"../CanvasLayer/Board/SubViewportContainer/SubViewport/Board2D"

func blur_in():
	$"../CanvasLayer/BlurPlayer".play("blur_in")

func blur_out():
	$"../CanvasLayer/BlurPlayer".play("blur_out")

func cinematic_in():
	$"../CanvasLayer/CinematicPlayer".play("in")

func cinematic_out():
	$"../CanvasLayer/CinematicPlayer".play("out")

func papa_in():
	$"../CanvasLayer/PapaPlayer".play("in")

func papa_out():
	$"../CanvasLayer/PapaPlayer".play("out")


var look_target = null

func player_look(target):
	look_target = target

func set_subtitle_skip_progress(v):
	var sm : ShaderMaterial = GLOBAL.subtitle_progress.material
	sm.set_shader_parameter("fill_ratio", v)
