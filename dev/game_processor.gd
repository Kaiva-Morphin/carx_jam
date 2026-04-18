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


@onready var svc = $"../CanvasLayer/SubViewportContainer"
@onready var sc = $"../CanvasLayer/Dialog"
func set_subviewport_size(size: Vector2):
	var rs = sc.size
	var ui_inv_scale = ui_target_size.x / size.x
	var ui_inv_scale2 = ui_target_size.y / size.y
	#var ui_inv_scale2 = size.x / get_viewport().get_visible_rect().size.x
	GLOBAL.player.dbg("CS", $"../CanvasLayer/Dialog".size)
	GLOBAL.player.dbg("RS", size)
	GLOBAL.player.dbg("IS2", ui_target_size) 
	if rs.x > ui_target_size.x :
		svc.scale = Vector2(ui_inv_scale2, ui_inv_scale2)
		svc.position = Vector2(0.0, 0.0)
	else:
		svc.scale = Vector2(ui_inv_scale, ui_inv_scale)
		# TODO!
	#svc.scale = Vector2(0.5, 0.5)
		#svc.position.y = svc.size.y / 2.0 - rs.y / 2.0
		#var scaled_size = svc.size * svc.scale
		#svc.position.y = (size.y - scaled_size.y) * 0.5
		
		#var d1 = (rs.x / rs.y)
		#var d2 = (size.x / size.y)
		#var d = d1 / d2
		#$"../CanvasLayer/SubViewportContainer".position.y = -dy * 0.5
	#$"../CanvasLayer/SubViewportContainer".scale = Vector2(ui_inv_scale2, ui_inv_scale2)
	#$"../CanvasLayer/SubViewportContainer".size = size
	$"../CanvasLayer/SubViewportContainer/SubViewport".size = size
	# 2560, 1369 : 1.0 
	# 1211, 648 : 0.473
	# 1152
	###
	#зкште
	#print(ui_target_size.x / size.x)
	#print($"../CanvasLayer/SubViewportContainer".size.y / size.y)
	#print(get_viewport().canvas_transform.)
	#print(get_viewport().get_canvas_transform().get_scale().y)
	#print(get_viewport().get_camera_3d().size)
	#print(ui_inv_scale)
	
	#print($"../CanvasLayer/SubViewportContainer".size)
	#var s = ui_inv_scale * size.x
	
	#$"../CanvasLayer/SubViewportContainer".scale = Vector2(ui_inv_scale, ui_inv_scale)
	#$"../CanvasLayer/SubViewportContainer".scale = Vector2(1.0, 1.0)
	#$"../CanvasLayer/SubViewportContainer".position.x = size.x / 2.0

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	return

func _process(_dt: float) -> void:
	if Input.is_action_just_pressed("unfocus"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func blur_in():
	$"../CanvasLayer/BlurPlayer".play("blur_in")

func blur_out():
	$"../CanvasLayer/BlurPlayer".play("blur_out")
