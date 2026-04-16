extends Node


enum DialogSpeaker {
	None,
	Character,
	Puddle
}


var dialogs = {
	"test": [
		{"speaker": DialogSpeaker.Character, "animation": "LeftConfused", "moveset": null, "text": """[center][font_size=16]правый"""},
		{"speaker": DialogSpeaker.Character, "animation": "LeftAngry", "moveset": null, "text": """[center][font_size=16]правый"""},
		{"speaker": DialogSpeaker.Puddle, "animation": "LeftConfused", "moveset": null, "text": """[center][font_size=16]левый"""},
		{"speaker": DialogSpeaker.Puddle, "animation": "LeftConfused", "moveset": null, "text": """[center][font_size=16]лувый"""},
	]
}
