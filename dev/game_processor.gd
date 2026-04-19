extends Node3D

enum iterrupter {
	DIALOG
}
var interrupters = {}


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
@onready var sc = $"../CanvasLayer/Dialog"
@onready var svc = $"../CanvasLayer/SubViewportContainer"
@onready var svc2 = $"../CanvasLayer/Board/SubViewportContainer"
func set_subviewport_size(size: Vector2):
	var rs = sc.size
	inv_ui_scale = ui_target_size.x / size.x
	var ui_inv_scale2 = ui_target_size.y / size.y
	GLOBAL.player.dbg("CS", $"../CanvasLayer/Dialog".size)
	GLOBAL.player.dbg("RS", DisplayServer.window_get_size())
	GLOBAL.player.dbg("IS2", ui_target_size) 
	# это пиздец
	if rs.x > ui_target_size.x :
		svc.scale = Vector2(ui_inv_scale2, ui_inv_scale2)
		svc.position = Vector2(0.0, 0.0)
	else:
		svc.scale = Vector2(inv_ui_scale, inv_ui_scale)
		svc.position = Vector2(0.0, -size.y * 0.5 * inv_ui_scale + ui_target_size.y * 0.5)
		GLOBAL.player.dbg("S", -size.y * 0.5)
	$"../CanvasLayer/SubViewportContainer/SubViewport".size = size
	$"../CanvasLayer/Board/SubViewportContainer/SubViewport".size = size
	svc2.scale = svc.scale

func _unhandled_input(event):
	if event is InputEventMouseButton && GLOBAL.ui_state == GLOBAL.UI_STATE.GAME:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_dt: float) -> void:
	#var size = DisplayServer.window_get_size()
	#set_subviewport_size(size)
	
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
			board.process_mode = Node.PROCESS_MODE_INHERIT
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
				GLOBAL.ui_state = GLOBAL.UI_STATE.INSPECTING


func close_tab():
	blur_out()
	board.hide()
	board.process_mode = Node.PROCESS_MODE_DISABLED
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GLOBAL.unblock_player()


@onready var board = $"../CanvasLayer/Board"
@onready var board2d = $"../CanvasLayer/Board/SubViewportContainer/SubViewport/Board2D"



func blur_in():
	$"../CanvasLayer/BlurPlayer".play("blur_in")

func blur_out():
	$"../CanvasLayer/BlurPlayer".play("blur_out")
