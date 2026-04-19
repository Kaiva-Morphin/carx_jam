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


func _on_size_changed():
	var size = DisplayServer.window_get_size()
	set_subviewport_size(size)



@onready var sc = $"../CanvasLayer/Dialog"
@onready var svc = $"../CanvasLayer/SubViewportContainer"
@onready var svc2 = $"../CanvasLayer/Board/SubViewportContainer"
func set_subviewport_size(size: Vector2):
	var rs = sc.size
	var ui_inv_scale = ui_target_size.x / size.x
	var ui_inv_scale2 = ui_target_size.y / size.y
	GLOBAL.player.dbg("CS", $"../CanvasLayer/Dialog".size)
	GLOBAL.player.dbg("RS", DisplayServer.window_get_size())
	GLOBAL.player.dbg("IS2", ui_target_size) 
	# это пиздец
	if rs.x > ui_target_size.x :
		svc.scale = Vector2(ui_inv_scale2, ui_inv_scale2)
		svc.position = Vector2(0.0, 0.0)
	else:
		svc.scale = Vector2(ui_inv_scale, ui_inv_scale)
		svc.position = Vector2(0.0, -size.y * 0.5 * ui_inv_scale + ui_target_size.y * 0.5)
		GLOBAL.player.dbg("S", -size.y * 0.5)
	$"../CanvasLayer/SubViewportContainer/SubViewport".size = size
	$"../CanvasLayer/Board/SubViewportContainer/SubViewport".size = size
	svc2.scale = svc.scale

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_dt: float) -> void:
	var size = DisplayServer.window_get_size()
	set_subviewport_size(size)
	
	if Input.is_action_just_pressed("unfocus"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("peek_hint"):
		for node in get_tree().get_nodes_in_group("visual_hint"): node.show()
	if Input.is_action_just_released("peek_hint"):
		for node in get_tree().get_nodes_in_group("visual_hint"): node.hide()
	if Input.is_action_just_pressed("open_tab"):
		tab_opened = !tab_opened
		if tab_opened:
			board.show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			board.hide()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

var tab_opened = false

@onready var board = $"../CanvasLayer/Board"



func blur_in():
	$"../CanvasLayer/BlurPlayer".play("blur_in")

func blur_out():
	$"../CanvasLayer/BlurPlayer".play("blur_out")
