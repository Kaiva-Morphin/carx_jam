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
var subtitle_progress : ColorRect
var inspect_cam_joint : Node3D
var hints : MarginContainer
var visual_hint = preload("res://game/visual_hint.tscn")
var subtitle_bg : TextureRect

enum UI_STATE {
	GAME,
	INSPECTING,
	BOARD,
	DIALOG,
	ATOM,
	RIDE,
	ROOM
}

var ui_state : UI_STATE = UI_STATE.RIDE

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
	CanRide,
	Room,
	Suspect,
	Lab,
	Final
}

var game_act = GameAct.Intro


var skip_intro = true # TODO
func _ready() -> void:
	if skip_intro:
		ui_state = UI_STATE.GAME
		game_act = GameAct.Home
	else:
		block_player()
		$"../Main/Player".process_mode = Node.PROCESS_MODE_DISABLED
		var a : AnimationPlayer = $"../Main/CanvasLayer/Intro"
		var b : AnimationPlayer = $"../Main/CanvasLayer/BlackPlayer"
		$"../Main/CanvasLayer/Black".show()
		$"../Main/CanvasLayer/Black2".show()
		b.play("in_const")
		a.play("play")
		ui_state = UI_STATE.RIDE
		a.animation_finished.connect(on_f)
		VOICEOVER.sequence_end.connect(on_s)


func on_s(s):
	if s != "first_ride": return
	GLOBAL.processor.black_out()
	ui_state = UI_STATE.GAME
	game_act = GameAct.Home
	unblock_player()


func on_f(_f):
	ui_state = UI_STATE.GAME
	# VOICEOVER.auto_next = true
	VOICEOVER.start_sequence("first_ride")


func _process(_dt: float) -> void:
	update_debug()
	
	#if game_act == GameAct.Intro:


var player_blocked = false
func block_player():
	if player:
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
