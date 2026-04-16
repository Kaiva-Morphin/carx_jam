extends Control

@onready var left = $Left
@onready var right = $Right
@onready var swapper = $Swapper


var is_dialog = false
var dialog_progress = 0
var next_dialog_progress = 0
var dialog_seq = []
var swap_animation_time = 0.3
var time_since_prev_dialog = 0
var speaker = DIALOGS.DialogSpeaker.None


func _ready() -> void:
	GLOBAL.dialog = self

signal dialog_end

func _process(delta):
	if is_dialog:
		if next_dialog_progress != dialog_progress:
			time_since_prev_dialog += delta
			if time_since_prev_dialog > swap_animation_time * 0.5:
				dialog_progress += 1
				var mv
				if dialog_seq[next_dialog_progress].has("moveset"):
					mv = dialog_seq[next_dialog_progress]["moveset"]
				if mv:
					$Emoter.play(mv)
				
				$Texturer.play(dialog_seq[next_dialog_progress]["animation"])
				if dialog_seq[next_dialog_progress]["speaker"] == DIALOGS.DialogSpeaker.Character:
					$Left/BG/Text.text = "\n\n" + dialog_seq[next_dialog_progress]["text"] + "\n\n"
				else:
					$Right/BG/Text.text = "\n\n" + dialog_seq[next_dialog_progress]["text"] + "\n\n"
		else:
			time_since_prev_dialog = 0
			if Input.is_action_just_pressed("dialog_next"):
				next_dialog_progress += 1
				if next_dialog_progress >= len(dialog_seq):
					is_dialog = false
					dialog_end.emit()
					swapper.play("RESET")
					$InspectObject.hide()
				else:
					var next_speaker = dialog_seq[next_dialog_progress]["speaker"]
					match speaker:
						DIALOGS.DialogSpeaker.None:
							match next_speaker:
								DIALOGS.DialogSpeaker.None:
									swapper.play("Left")
								DIALOGS.DialogSpeaker.Character:
									swapper.play("LeftAppear")
								DIALOGS.DialogSpeaker.Puddle:
									swapper.play("RightAppear")
						DIALOGS.DialogSpeaker.Character:
							match next_speaker:
								DIALOGS.DialogSpeaker.None:
									swapper.play("Left")
								DIALOGS.DialogSpeaker.Character:
									swapper.play("LeftToLeft")
								DIALOGS.DialogSpeaker.Puddle:
									swapper.play("LeftToRight")
						DIALOGS.DialogSpeaker.Puddle:
							match next_speaker:
								DIALOGS.DialogSpeaker.None:
									swapper.play("Right")
								DIALOGS.DialogSpeaker.Character:
									swapper.play("RightToLeft")
								DIALOGS.DialogSpeaker.Puddle:
									swapper.play("RightToRight")
					speaker = next_speaker

func inspect(img, comment):
	$"Emoter".play("RESET")
	$"Texturer".play("LeftTalk")
	$"Swapper".play("Comment")
	$"Left/BG/Text".text = comment
	$InspectObject.show()
	$InspectObject.texture = load(img)
	self.is_dialog = true
	self.dialog_progress = -1
	self.next_dialog_progress = 0
	self.dialog_seq = [{"speaker": DIALOGS.DialogSpeaker.Character, "animation": "LeftTalk", "moveset": "LeftIdle", "text": comment}]

#func _ready():
	#show_dialog([
		#{"speaker": DIALOGS.DialogSpeaker.Character, "animation": "LeftConfused", "moveset": null, "text": """[center][font_size=16]правый"""},
		#{"speaker": DIALOGS.DialogSpeaker.Character, "animation": "LeftAngry", "moveset": null, "text": """[center][font_size=16]правый"""},
		#{"speaker": DIALOGS.DialogSpeaker.Puddle, "animation": "LeftConfused", "moveset": null, "text": """[center][font_size=16]правый"""},
		#{"speaker": DIALOGS.DialogSpeaker.Puddle, "animation": "LeftConfused", "moveset": null, "text": """[center][font_size=16]правый"""},
	#])

func show_dialog(sequence):
	if len(sequence) == 0: return
	swapper.play("RESET")
	$Left/BG/Text.text = ""
	$Right/BG/Text.text = ""
	is_dialog = true
	dialog_progress = -1
	next_dialog_progress = 0
	dialog_seq = sequence
	if sequence[0]["speaker"] == DIALOGS.DialogSpeaker.Character:
		swapper.play("LeftAppear")
		
	else:
		swapper.play("RightAppear")
	speaker = sequence[0]["speaker"]

func start_dialog():
	swapper.play("RESET")
	$Left/BG/Text.text = ""
	$Right/BG/Text.text = ""
	is_dialog = true
	dialog_progress = -1
	next_dialog_progress = 0
	self.dialog_seq = [
		{"speaker": DIALOGS.DialogSpeaker.Character, "animation": "LeftConfused", "moveset": "LeftConfused", "text": """[center][font_size=16][tornado]че разлегся?[/tornado][/font_size] """},
		{"speaker": DIALOGS.DialogSpeaker.Character, "animation": "RESET", "moveset": "RESET", "text": "[center][font_size=32]лужа"},
		{"speaker": DIALOGS.DialogSpeaker.Puddle, "animation": "RightTalk", "moveset": "RightIdle", "text": "[center][font_size=16]че?"},
		{"speaker": DIALOGS.DialogSpeaker.Character, "animation": "LeftTalk", "moveset": "RightIdle", "text": "[center][wave]хихихи[/wave] [font_size=30][shake]ПОДВИНЬСЯ"},
		{"speaker": DIALOGS.DialogSpeaker.Puddle, "animation": "RightTalkAngry", "moveset": "RightAngry", "text": '''[center][font_size=46][shake]ОТВАЛИ'''},
	]
	if dialog_seq[0]["speaker"] == DIALOGS.DialogSpeaker.Character:
		swapper.play("LeftAppear")
	else:
		swapper.play("RightAppear")
	self.speaker = dialog_seq[0]["speaker"]
	
