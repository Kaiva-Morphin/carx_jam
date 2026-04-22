extends Node

const path = "res://assets/voiceover_silence/"


var voiceparts = {
	#region mono
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

var sequences = {
	#region mono
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
	"morty_1": ["morty_hello", "morty_hello"],
	"lab_1": ["lab_1", "lab_2"],
	"lab_2": ["lab_3", "lab_4"],
	"lab_3": ["morty_hello", "morty_hello"],
	"lab_4": ["morty_hello", "morty_hello"],
	"lab_5": ["lab_end", "lab_end"],
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

func _init() -> void:
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
		return
	var next = sequence.pop_front()
	var data = voiceparts[next]
	var a : AudioStreamPlayer = data.node
	a.play(0)
	current_voiceline = a
	var text = tr(data.text)
	GLOBAL.subtitle.text = """[center][font otv="wght=600"]""" + text
	var clean_text = text.replace(r"\[.*?\]", "")
	current_progress = 0.0
	GLOBAL.subtitle.visible_characters = 0
	sequence_text_size = clean_text.length()
	gps = sequence_text_size / a.stream.get_length()
	running = true


var skip_d = 0.0
var skip_time = 0.5
var loss = 1.5
var ended = false
func _process(_dt):
	if !GLOBAL.processor: return
	if running:
		GLOBAL.subtitle_bg.modulate.a = lerp(GLOBAL.subtitle_bg.modulate.a, 1.0, _dt * 10.0)
	if !running:
		GLOBAL.subtitle_bg.modulate.a = lerp(GLOBAL.subtitle_bg.modulate.a, 0.0, _dt * 10.0)
		GLOBAL.processor.set_subtitle_skip_progress(0.0)
		return
	current_progress += gps * _dt
	GLOBAL.subtitle.visible_characters = int(current_progress)
	if GLOBAL.subtitle.visible_characters > sequence_text_size && auto_next:
		sequence_next()
		return
	if Input.is_action_pressed("dialog_next"):
		if GLOBAL.subtitle.visible_characters > sequence_text_size:
			sequence_next()
		skip_d += _dt
		if skip_d > skip_time:
			sequence_next()
	else:
		if skip_d < -0.1:
			skip_d += _dt * loss
		else:
			skip_d -= _dt * loss
	GLOBAL.processor.set_subtitle_skip_progress(skip_d / skip_time)

func pause():
	if current_voiceline:
		current_voiceline.pause()
	running = false

func resume():
	if current_voiceline:
		current_voiceline.resume()
	running = true
