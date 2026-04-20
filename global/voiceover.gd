extends Node

const path = "res://assets/voiceover/"

var voiceparts = {
	
	"morty_hello" : {
		"voice" : preload(path + "morty_hello.mp3"),
		"text": "KEY_VOICELINE_MORTY_HELLO",
	}
}

var sequences = {
	"test": [],
	"morty_1": ["morty_hello", "morty_hello"]
}

signal sequence_end(key: String)

var current_dialog = null
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
	var p = sequences[key].duplicate(true)
	if !p:
		printerr("No key for dialog: ", key)
		return
	sequence = p
	current_key = key
	sequence_next()

func sequence_next():
	skip_d = -0.5
	if current_voiceline:
		current_voiceline.stop()
	current_voiceline = null
	if len(sequence) == 0:
		sequence_end.emit(current_key)
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
	if !running:
		GLOBAL.processor.set_subtitle_skip_progress(0.0)
		return
	current_progress += gps * _dt
	GLOBAL.subtitle.visible_characters = int(current_progress)
	if Input.is_action_pressed("dialog_next"):
		if GLOBAL.subtitle.visible_characters > sequence_text_size:
			sequence_next()
		skip_d += _dt
		if skip_d > skip_time:
			sequence_next()
	else:
		if skip_d < -0.2:
			skip_d += _dt * loss
		else:
			skip_d -= _dt * loss
		#skip_d = max(-0.5, skip_d)
	GLOBAL.processor.set_subtitle_skip_progress(skip_d / skip_time)

func pause():
	if current_voiceline:
		current_voiceline.pause()
	running = false

func resume():
	if current_voiceline:
		current_voiceline.resume()
	running = true
