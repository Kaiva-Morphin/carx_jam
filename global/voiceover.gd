extends Node

const path = "res://assets/voiceover_silence/"


var voiceparts = {
	"first_ride" : {"voice" : preload(path + "first_ride.mp3"),"text": "KEY_FIRST_RIDE",},
	"first_ride2" : {"voice" : preload(path + "first_ride2.mp3"),"text": "KEY_FIRST_RIDE2",},
	"first_ride3" : {"voice" : preload(path + "first_ride3.mp3"),"text": "KEY_FIRST_RIDE3",},
	
	"room1" : {"voice" : preload(path + "first_ride3.mp3"),"text": "KEY_ROOM1",},
	"room2" : {"voice" : preload(path + "first_ride3.mp3"),"text": "KEY_ROOM2",},
	
	"second_ride" : {"voice" : preload(path + "second_ride.mp3"),"text": "KEY_SECOND_RIDE",},
	
	"third_ride" : {"voice" : preload(path + "third_ride.mp3"),"text": "KEY_THIRD_RIDE",},
	
	#region mono
	"ride" : {
		"voice" : preload(path + "ride.mp3"),
		"text": "KEY_MONO_RIDE",
	},
	"mono_act1" : {
		"voice" : preload(path + "mono_act1.mp3"),
		"text": "KEY_MONO_ACT1",
	},
	"mono_mail" : {
		"voice" : preload(path + "mono_mail.mp3"),
		"text": "KEY_MONO_MAIL",
	},
	"mono_bio_blood" : {
		"voice" : preload(path + "mono_bio_blood.mp3"),
		"text": "KEY_MONO_BIO_BLOOD",
	},
	"mono_hallway" : {
		"voice" : preload(path + "mono_hallway.mp3"),
		"text": "KEY_MONO_HALLWAY",
	},
	"mono_living_bottles" : {
		"voice" : preload(path + "mono_living_bottles.mp3"),
		"text": "KEY_MONO_LIVING_BOTTLES",
	},
	"mono_living_bottles_done" : {
		"voice" : preload(path + "mono_living_bottles_done.mp3"),
		"text": "KEY_MONO_LIVING_BOTTLES_DONE",
	},
	"mono_demyan_room_table" : {
		"voice" : preload(path + "mono_demyan_room_table.mp3"),
		"text": "KEY_MONO_DEMYAN_ROOM_TABLE",
	},
	"mono_living_cig" : {
		"voice" : preload(path + "mono_living_cig.mp3"),
		"text": "KEY_MONO_LIVING_CIG",
	},
	"mono_living_photo" : {
		"voice" : preload(path + "mono_living_photo.mp3"),
		"text": "KEY_MONO_LIVING_PHOTO",
	},
	"mono_safe" : {
		"voice" : preload(path + "mono_safe.mp3"),
		"text": "KEY_MONO_SAFE",
	},
	"mono_diploma" : {
		"voice" : preload(path + "mono_diploma.mp3"),
		"text": "KEY_MONO_DIPLOMA",
	},
	"mono_compare" : {
		"voice" : preload(path + "mono_compare.mp3"),
		"text": "KEY_MONO_COMPARE",
	},
	"mono_trash" : {
		"voice" : preload(path + "mono_trash.mp3"),
		"text": "KEY_MONO_TRASH",
	},
	"mono_backdoor" : {
		"voice" : preload(path + "mono_backdoor.mp3"),
		"text": "KEY_MONO_BACKDOOR",
	},
	"mono_backdoor_lock" : {
		"voice" : preload(path + "mono_backdoor_lock.mp3"),
		"text": "KEY_MONO_BACKDOOR_LOCK",
	},
	"mono_footprints" : {
		"voice" : preload(path + "mono_footprints.mp3"),
		"text": "KEY_MONO_FOOTPRINTS",
	},
	"mono_trash_bin" : {
		"voice" : preload(path + "mono_trash_bin.mp3"),
		"text": "KEY_MONO_TRASH_BIN",
	},
	"mono_demyan_room" : {
		"voice" : preload(path + "mono_demyan_room.mp3"),
		"text": "KEY_MONO_DEMYAN_ROOM",
	},
	"mono_books" : {
		"voice" : preload(path + "mono_books.mp3"),
		"text": "KEY_MONO_BOOKS",
	},
	"mono_drawings" : {
		"voice" : preload(path + "mono_drawings.mp3"),
		"text": "KEY_MONO_DRAWINGS",
	},
	"mono_room" : {
		"voice" : preload(path + "mono_room.mp3"),
		"text": "KEY_MONO_ROOM",
	},
	"mono_father_safe" : {
		"voice" : preload(path + "mono_father_safe.mp3"),
		"text": "KEY_MONO_FATHER_SAFE",
	},
	"mono_suitcase" : {
		"voice" : preload(path + "mono_suitcase.mp3"),
		"text": "KEY_MONO_SUITCASE",
	},
	"mono_flask" : {
		"voice" : preload(path + "mono_flask.mp3"),
		"text": "KEY_MONO_FLASK",
	},
	"mono_box" : {
		"voice" : preload(path + "mono_box.mp3"),
		"text": "KEY_MONO_BOX",
	},
	"mono_attic_photo" : {
		"voice" : preload(path + "mono_attic_photo.mp3"),
		"text": "KEY_MONO_ATTIC_PHOTO",
	},
	"mono_father_room" : {
		"voice" : preload(path + "mono_father_room.mp3"),
		"text": "KEY_MONO_FATHER_ROOM",
	},
	"mono_safe_key": {
		"voice" : preload(path + "mono_safe_key.mp3"),
		"text": "KEY_MONO_SAFE_KEY",
	},
	"mono_main_entrance" : {
		"voice" : preload(path + "mono_main_entrance.mp3"),
		"text": "KEY_MONO_SAFE_KEY",
	},

	#endregion mono
	
	"morty_hello" : {
		"voice" : preload(path + "morty_hello.mp3"),
		"text": "KEY_VOICELINE_MORTY_HELLO",
	},
	"lab_1" : {"voice" : preload(path + "morty_hello.mp3"),"text": "1",},
	"lab_2" : {"voice" : preload(path + "morty_hello.mp3"),"text": "2",},
	"lab_3" : {"voice" : preload(path + "morty_hello.mp3"),"text": "3",},
	"lab_4" : {"voice" : preload(path + "morty_hello.mp3"),"text": "4",},
	"lab_end" : {
		"voice" : preload(path + "morty_hello.mp3"),
		"text": "KEY_VOICELINE_LAB_END",
	}
}

func v(v):
	return {"voice": "0.mp3", "text": v}

var sequences = {
	"first_ride": ["first_ride", "first_ride2", "first_ride3"],
	"second_ride": ["second_ride"],
	"third_ride": ["third_ride"],
	"room1": [
		v("ROOM1"),
		v("ROOM2"),
		v("ROOM2_2"),
	],
	"room2": [
		v("ROOM3"),
		v("ROOM4"),
		v("ROOM5"),
		v("ROOM6"),
		v("ROOM7"),
		v("ROOM8"),
		v("ROOM9"),
		v("ROOM10"),
		v("ROOM11"),
		v("ROOM12"),
		v("ROOM13"),
		v("ROOM14"),
		v("ROOM15"),
		v("ROOM16"),
		v("ROOM17"),
		v("ROOM18"),
		v("ROOM19"),
		v("ROOM20"),
		v("ROOM21"),
		v("ROOM22"),
		v("ROOM23"),
		v("ROOM24"),
		v("ROOM25"),
		v("ROOM26")
	],
	"pre_lab": [
		v("STAGE_1_ZOLLER_1"),
		v("STAGE_1_ZOLLER_2"),
		v("STAGE_1_ALEX_1"),
		v("STAGE_1_ALEX_2"),
		v("STAGE_1_ZOLLER_3"),
		v("STAGE_1_ZOLLER_4"),
	],
	"lab1": [
		v("STAGE_1_ZOLLER_5"),
		v("STAGE_1_ALEX_3"),
		v("STAGE_1_ZOLLER_6"),
		v("STAGE_1_ZOLLER_7"),
	],
	"lab2": [
		v("STAGE_1_ZOLLER_8"),
		v("STAGE_1_ZOLLER_9"),
		v("STAGE_1_ZOLLER_10"),
		v("STAGE_1_ALEX_4"),
		v("STAGE_1_ALEX_5"),
		v("STAGE_1_ALEX_6"),
		v("STAGE_1_ZOLLER_11"),
		v("STAGE_1_ZOLLER_12"),
		v("STAGE_1_ZOLLER_13"),
		v("STAGE_1_ZOLLER_14"),
		v("STAGE_1_ALEX_7"),
		v("STAGE_1_ALEX_8"),
	],
	"lab3": [
		v("STAGE_1_ZOLLER_15"),
		v("STAGE_1_ALEX_9"),
		v("STAGE_1_ZOLLER_16"),
		v("STAGE_1_ZOLLER_17"),
		v("STAGE_1_ZOLLER_18"),
		v("STAGE_1_ALEX_10"),
		v("STAGE_1_ALEX_11"),
	],
	"lab4": [
		v("STAGE_1_ZOLLER_19"),
		v("STAGE_1_ZOLLER_20"),
		v("STAGE_1_ZOLLER_21"),
		v("STAGE_1_ZOLLER_22"),
		v("STAGE_1_ZOLLER_23"),
		v("STAGE_1_ZOLLER_24"),
		v("STAGE_1_ALEX_12"),
		v("STAGE_1_ZOLLER_25"),
		v("STAGE_1_ZOLLER_26"),
		v("STAGE_1_ALEX_13"),
		v("STAGE_1_ALEX_14"),
		v("STAGE_1_ALEX_15"),
		v("STAGE_1_ALEX_16"),
		v("STAGE_1_ALEX_17"),
		v("STAGE_1_ZOLLER_27"),
		v("STAGE_1_ALEX_18"),
		v("STAGE_1_ZOLLER_28"),
		v("STAGE_1_ZOLLER_29"),
		v("STAGE_1_ALEX_19"),
		v("STAGE_1_ALEX_20"),
		v("STAGE_1_ZOLLER_29"),
		v("STAGE_1_ZOLLER_30"),
		v("STAGE_1_ZOLLER_31"),
		v("STAGE_1_ZOLLER_32"),
		v("STAGE_1_ALEX_21"),
		v("STAGE_1_ALEX_22"),
		v("STAGE_1_ZOLLER_33"),
		v("STAGE_1_ZOLLER_34"),
		v("STAGE_1_ALEX_23"),
		v("STAGE_1_AFT1"),
		v("STAGE_1_AFT2"),
		v("STAGE_1_AFT3"),
		v("STAGE_1_AFT4"),
		v("STAGE_1_AFT5"),
		v("STAGE_1_AFT6"),
		v("STAGE_1_AFT7"),
		v("STAGE_1_AFT8"),
		v("STAGE_1_AFT9"),
	],
	"fourth_ride": [v("KEY_FOURTH_RIDE")],
	
	#region mono
	"ride": ["ride"],
	"mono_bio_blood": ["mono_bio_blood"],
	"mono_act1": ["mono_act1"],
	"mono_mail": ["mono_mail"],
	"mono_main_entrance": ["mono_main_entrance"],
	"mono_hallway": ["mono_hallway"],
	"mono_living_bottles": ["mono_living_bottles"],
	"mono_living_bottles_done": ["mono_living_bottles_done"],
	"mono_living_cig": ["mono_living_cig"],
	"mono_living_photo": ["mono_living_photo"],
	"mono_safe": ["mono_safe"],
	"mono_diploma": ["mono_diploma"],
	"mono_compare": ["mono_compare"],
	"mono_trash": ["mono_trash"],
	"mono_backdoor": ["mono_backdoor"],
	"mono_backdoor_lock": ["mono_backdoor_lock"],
	"mono_footprints": ["mono_footprints"],
	"mono_trash_bin": ["mono_trash_bin"],
	"mono_demyan_room": ["mono_demyan_room"],
	"mono_books": ["mono_books"],
	"mono_drawings": ["mono_drawings"],
	"mono_room": ["mono_room"],
	"mono_father_room": ["mono_father_room"],
	"mono_father_safe": ["mono_father_safe"],
	"mono_suitcase": ["mono_suitcase"],
	"mono_flask": ["mono_flask"],
	"mono_box": ["mono_box"],
	"mono_attic_photo": ["mono_attic_photo"],
	"mono_demyan_room_table": ["mono_demyan_room_table"],
	"mono_safe_key": ["mono_safe_key"],
	#endregion mono
	"test": [],
}

signal sequence_end(key: String)

var auto_next = false
var current_progress = 0.0
var gps = 0.0
var current_voiceline : AudioStreamPlayer = null
var sequence = []
var running = false
var current_key = "test"
var sequence_text_size = 0

var pushed = null
func push_sequence(k):
	if !current_voiceline:
		start_sequence(k)
	else:
		pushed = k

var temp_vl: AudioStreamPlayer
func _init() -> void:
	var vl = AudioStreamPlayer.new()
	vl.stream = preload(path + "0.mp3")
	add_child(vl)
	temp_vl = vl
	for k in voiceparts:
		var p = AudioStreamPlayer.new()
		p.stream = voiceparts[k].voice 
		add_child(p)
		voiceparts[k].node = p

func start_sequence(key):
	if current_voiceline:
		current_voiceline.stop()
		current_voiceline = null
		sequence_end.emit(current_key)
		running = false
		GLOBAL.subtitle.visible_characters = 0
		GLOBAL.subtitle.text = ""
	var p = sequences[key].duplicate(true)
	if !p:
		printerr("No key for dialog: ", key)
		return
	sequence = p
	current_key = key
	sequence_next()

func sequence_next():
	skip_d = -0.2
	if current_voiceline:
		current_voiceline.stop()
	current_voiceline = null
	if len(sequence) == 0:
		sequence_end.emit(current_key)
		auto_next = false
		running = false
		GLOBAL.subtitle.visible_characters = 0
		GLOBAL.subtitle.text = ""
		if pushed:
			auto_next = true
			start_sequence(pushed)
			pushed = null
		return
	var next = sequence.pop_front()
	var data
	if next is Dictionary:
		data = next
	else:
		data = voiceparts[next]
	
	var n = data.get("node")
	if n:
		var a : AudioStreamPlayer = n
		a.play(0)
		current_voiceline = a
	else:
		temp_vl.play(0)
		current_voiceline = temp_vl
	var text = tr(data.text)
	GLOBAL.subtitle.text = """[center][font otv="wght=600"]""" + text
	var clean_text = text.replace(r"\[.*?\]", "")
	current_progress = 0.0
	GLOBAL.subtitle.visible_characters = 0
	sequence_text_size = clean_text.length()
	#gps = sequence_text_size / a.stream.get_length()
	gps = 30
	running = true


var skip_d = 0.0
var skip_time = 0.5
var loss = 1.5
var ended = false
func _process(_dt):
	if !GLOBAL.processor: return
	if running:
		#GLOBAL.subtitle_bg.modulate.a = lerp(GLOBAL.subtitle_bg.modulate.a, 1.0, _dt * 10.0)
		pass
	if !running:
		#GLOBAL.subtitle_bg.modulate.a = lerp(GLOBAL.subtitle_bg.modulate.a, 0.0, _dt * 10.0)
		#GLOBAL.processor.set_subtitle_skip_progress(0.0)
		return
	current_progress += gps * _dt
	GLOBAL.subtitle.visible_characters = int(current_progress)
	if GLOBAL.subtitle.visible_characters > sequence_text_size && auto_next:
		sequence_next()
		return
	if Input.is_action_just_pressed("dialog_next"):
		if GLOBAL.subtitle.visible_characters > sequence_text_size:
			sequence_next()
		else:
			current_progress = sequence_text_size
		#skip_d += _dt
		#if skip_d > skip_time:
			#sequence_next()
	#else:
		#if skip_d < -0.1:
			#skip_d += _dt * loss
		#else:
			#skip_d -= _dt * loss
	#GLOBAL.processor.set_subtitle_skip_progress(skip_d / skip_time)

func pause():
	if current_voiceline:
		current_voiceline.pause()
	running = false

func resume():
	if current_voiceline:
		current_voiceline.resume()
	running = true
