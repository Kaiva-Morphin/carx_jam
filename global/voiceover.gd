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
	gps = clean_text.length() / a.stream.get_length()
	running = true

func _process(_dt):
	if !running: return
	if Input.is_action_just_pressed("dialog_next"):
		sequence_next()
	current_progress += gps * _dt
	GLOBAL.subtitle.visible_characters = int(current_progress)

func pause():
	if current_voiceline:
		current_voiceline.pause()
	running = false

func resume():
	if current_voiceline:
		current_voiceline.resume()
	running = true
