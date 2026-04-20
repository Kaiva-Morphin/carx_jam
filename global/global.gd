extends Node

var player : CharacterBody3D
var dialog : Control
var hint_node : Label
var interaction_ray : RayCast3D
var inspect_cam : Camera3D
var inspect_node : Node3D
var processor : Node3D
var dbg_label : Label
var subtitle : RichTextLabel

enum UI_STATE {
	GAME,
	INSPECTING,
	BOARD,
	DIALOG
}

var ui_state : UI_STATE

var debug = {}

func dbg(key, value):
	debug[key] = value

func update_debug():
	var dbgs = []
	var keys = debug.keys()
	keys.sort()
	for key in keys:
		dbgs.append(key+" "+str(debug[key]))
	dbgs.append("FPS:"+str(Engine.get_frames_per_second()))
	if dbg_label:
		dbg_label.text = "\n".join(dbgs)

enum GameAct {
	Intro,
	Home,
	Suspect,
	Lab,
	Final
}

func _process(_dt: float) -> void:
	update_debug()

var player_blocked = false
func block_player():
	player_blocked = true
	player.process_mode = Node.PROCESS_MODE_DISABLED

func unblock_player():
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	player_blocked = false
	(func(): player.process_mode = Node.PROCESS_MODE_INHERIT).call_deferred()
