extends Node
class_name RumorManager

signal hearing_unlocked(key)
signal image_discovered(key)
signal description_unlocked(hearing_key, index)
signal connection_unlocked(from_key, to_key, desc)

var hearings_state = {}
var knowledge = {}

func _ready():
	_init_state()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shader"): # TODO
		all_knowledge()
	



func _init_state():
	for key in hearings_data.keys():
		var data = hearings_data[key]
		hearings_state[key] = {
			"unlocked": false,
			"descriptions": [],
			"connections": []
		}
		for i in data.descriptions.size():
			hearings_state[key].descriptions.append(false)
		for i in data.connections.size():
			hearings_state[key].connections.append(false)

func add_knowledge(flag: String):
	if knowledge.get(flag, false):
		return

	knowledge[flag] = true
	_update_all()

func _update_all():
	for key in hearings_data.keys():
		_update_hearing(key)

func _update_hearing(key: String):
	var data = hearings_data[key]
	var state = hearings_state[key]
	var any_unlocked = false
	for i in data.descriptions.size():
		if state.descriptions[i]:
			any_unlocked = true
			continue
		var cond = data.descriptions[i].cond
		if knowledge.get(cond, false):
			if cond in data.image_cond:
				emit_signal("image_discovered", key)
			state.descriptions[i] = true
			any_unlocked = true
			emit_signal("description_unlocked", key, i)
	if any_unlocked and not state.unlocked:
		state.unlocked = true
		emit_signal("hearing_unlocked", key)
	for i in data.connections.size():
		if state.connections[i]:
			continue
		var cond = data.connections[i].cond
		if knowledge.get(cond, false):
			state.connections[i] = true
			emit_signal("connection_unlocked", key, data.connections[i].to, data.connections[i].description)

func get_hearing(key: String):
	return hearings_data.get(key, null)

func get_state(key: String):
	return hearings_state.get(key, null)

func is_unlocked(key: String) -> bool:
	return hearings_state[key].unlocked

func get_unlocked_descriptions(key: String) -> Array:
	var result = []
	var data = hearings_data[key]
	var state = hearings_state[key]
	for i in data.descriptions.size():
		if state.descriptions[i]:
			result.append(data.descriptions[i].text)
	return result



enum RumorImage {
	UNK,
	MURDER,
	OFFICIAL,
	
	#region mono
	ORIGINAL_BOARD,
	TAPE,
	BREAK_IN,
	SNEAKERS,
	BIO_1,
	MISSING_BOTTLE,
	MAIL,
	CIG,
	SAFE,
	DOCUMENTS,
	BIO_2,
	LETTER,
	DRAWINGS,
	PASSPORT,
	FLASK,
	PHOTO
	#endregion mono
}

func all_knowledge():
	for h in hearings_data:
		var hd = hearings_data[h]
		for c in hd.connections:
			add_knowledge(c.cond)
		for i in hd.image_cond:
			add_knowledge(i)
		for d in hd.descriptions:
			add_knowledge(d.cond)

var hearings_data = {
		"UNK": {
			"title": "KEY_BOARD_UNK_TITLE",
			"descriptions": [{ "text": "UNK", "cond": "unk" }],
			"connections": [],
			"image": RumorImage.UNK,
			"image_cond": ["original_board"],
			"position": Vector2(-800, 1300)
		},
		#region initial
		"MURDER": {
			"title": "KEY_BOARD_MURDER_TITLE",
			"descriptions": [
				{ "text": "KEY_BOARD_MURDER1", "cond": "original_board" },
				{ "text": "KEY_BOARD_MURDER2", "cond": "original_board" },
				{ "text": "KEY_BOARD_MURDER3", "cond": "original_board" },
			],
			"connections": [],
			"image": RumorImage.MURDER,
			"image_cond": [],
			"position": Vector2(0, 0)
		},
		"OFFICIAL": {
			"title": "KEY_BOARD_OFFICIAL_TITLE",
			"descriptions": [
				{ "text": "KEY_BOARD_OFFICIAL1", "cond": "original_board" },
			],
			"connections": [{"to": "MURDER", "cond": "original_board", "description": "KEY_BOARD_OFFICIAL_TITLE"}],
			"image": RumorImage.OFFICIAL,
			"image_cond": [],
			"position": Vector2(400, -1200)
		},
		"OFFICIAL_MURDERER": {
			"title": "KEY_BOARD_OFFICIAL_MURDERER_TITLE",
			"descriptions": [
				{ "text": "KEY_BOARD_OFFICIAL_MURDERER1", "cond": "original_board" },
				{ "text": "KEY_BOARD_OFFICIAL_MURDERER2", "cond": "original_board" },
				{ "text": "KEY_BOARD_OFFICIAL_MURDERER3", "cond": "original_board" },
				{ "text": "KEY_BOARD_OFFICIAL_MURDERER4", "cond": "original_board" },
			],
			"connections": [{"to": "OFFICIAL", "cond": "original_board", "description": "KEY_BOARD_OFFICIAL_TITLE"}],
			"image": RumorImage.OFFICIAL,
			"image_cond": [],
			"position": Vector2(900, -900)
		},
		
		"FATHER_MONEY": {
			"title": "KEY_BOARD_FATHER_MONEY_TITLE",
			"descriptions": [
				{ "text": "KEY_BOARD_FATHER_MONEY1", "cond": "original_board" },
			],
			"connections": [{"to": "OFFICIAL_MURDERER", "cond": "original_board", "description": "KEY_BOARD_OFFICIAL_TITLE"}],
			"image": RumorImage.OFFICIAL,
			"image_cond": [],
			"position": Vector2(1600, -900)
		},
		
		#endregion initial
		#region mono
		"TAPE": {
			"title": "KEY_BOARD_TAPE_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_TAPE", "cond": "tape" }],
			"connections": [],
			"image": RumorImage.TAPE,
			"image_cond": [],
			"position": Vector2(-3000, 200)
		},
		"BREAK_IN": {
			"title": "KEY_BOARD_BREAKIN_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_BREAK_IN", "cond": "break_in" }],
			"connections": [],
			"image": RumorImage.BREAK_IN,
			"image_cond": [],
			"position": Vector2(-3000, 400)
		},
		"SNEAKERS": {
			"title": "KEY_BOARD_SNEAKERS_TITLE",
			"descriptions": [
				{ "text": "KEY_BOARD_SNEAKERS1", "cond": "sneakers" },
			],
			"connections": [{"description": "KEY_BOARD_SNEAKERS_CONN", "cond": "sneakers", "to": "UNK"}],
			"image": RumorImage.SNEAKERS,
			"image_cond": ["sneakers"],
			"position": Vector2(-1000, 600)
		},
		"BIO_1": {
			"title": "KEY_BOARD_BIO1_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_BIO_1", "cond": "bio1" }],
			"connections": [],
			"image": RumorImage.BIO_1,
			"image_cond": [],
			"position": Vector2(-3000, 800)
		},
		"MISSING_BOTTLE": {
			"title": "KEY_BOARD_MISSING_BOTTLE_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_MISSING_BOTTLE", "cond": "missing_bottle" }],
			"connections": [],
			"image": RumorImage.MISSING_BOTTLE,
			"image_cond": [],
			"position": Vector2(-3000, 1000)
		},
		"MAIL": {
			"title": "KEY_BOARD_MAIL_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_MAIL", "cond": "mail" }],
			"connections": [],
			"image": RumorImage.MAIL,
			"image_cond": [],
			"position": Vector2(-3000, 1200)
		},
		"CIG": {
			"title": "KEY_BOARD_CIG_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_CIG", "cond": "cig" }],
			"connections": [],
			"image": RumorImage.CIG,
			"image_cond": [],
			"position": Vector2(-3000, 1400)
		},
		"SAFE": {
			"title": "KEY_BOARD_SAFE_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_SAFE", "cond": "safe" }],
			"connections": [],
			"image": RumorImage.SAFE,
			"image_cond": [],
			"position": Vector2(-3000, 1600)
		},
		"DOCUMENTS": {
			"title": "KEY_BOARD_DOCS_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_DOCS", "cond": "docs" }],
			"connections": [],
			"image": RumorImage.DOCUMENTS,
			"image_cond": [],
			"position": Vector2(-3000, 1800)
		},
		"BIO_2": {
			"title": "KEY_BOARD_BIO_2_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_BIO_2", "cond": "bio2" }],
			"connections": [],
			"image": RumorImage.BIO_2,
			"image_cond": [],
			"position": Vector2(-3000, 2000)
		},
		"LETTER": {
			"title": "KEY_BOARD_LETTER_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_LETTER", "cond": "letter" }],
			"connections": [],
			"image": RumorImage.LETTER,
			"image_cond": [],
			"position": Vector2(-3000, 2200)
		},
		"DRAWINGS": {
			"title": "KEY_BOARD_DRAWINGS_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_DRAWINGS", "cond": "drawings" }],
			"connections": [],
			"image": RumorImage.DRAWINGS,
			"image_cond": [],
			"position": Vector2(-3000, 2400)
		},
		"PASSPORT": {
			"title": "KEY_BOARD_PASSPORT_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_PASSPORT", "cond": "passport" }],
			"connections": [],
			"image": RumorImage.PASSPORT,
			"image_cond": [],
			"position": Vector2(-3000, 2600)
		},
		"FLASK": {
			"title": "KEY_BOARD_FLASK_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_FLASK", "cond": "flask" }],
			"connections": [],
			"image": RumorImage.FLASK,
			"image_cond": [],
			"position": Vector2(-3000, 2800)
		},
		"PHOTO": {
			"title": "KEY_BOARD_PHOTO_TITLE",
			"descriptions": [{ "text": "KEY_BOARD_PHOTO", "cond": "photo" }],
			"connections": [],
			"image": RumorImage.PHOTO,
			"image_cond": [],
			"position": Vector2(-3000, 3000)
		}
		#endregion mono
	}

const path = "res://assets/rumor_images_transparent/"
func image(key):
	match key:
		#region mono
		RumorImage.ORIGINAL_BOARD: return preload(path + "original_board.png")
		RumorImage.UNK: return preload(path + "unk.png")
		RumorImage.TAPE: return preload(path + "tape.png")
		RumorImage.BREAK_IN: return preload(path + "break_in.png")
		RumorImage.SNEAKERS: return preload(path + "sneakers.png")
		RumorImage.BIO_1: return preload(path + "bio_1.png")
		RumorImage.MISSING_BOTTLE: return preload(path + "missing_bottle.png")
		RumorImage.MAIL: return preload(path + "mail.png")
		RumorImage.CIG: return preload(path + "cig.png")
		RumorImage.SAFE: return preload(path + "safe.png")
		RumorImage.DOCUMENTS: return preload(path + "documents.png")
		RumorImage.BIO_2: return preload(path + "bio_2.png")
		RumorImage.LETTER: return preload(path + "letter.png")
		RumorImage.DRAWINGS: return preload(path + "drawings.png")
		RumorImage.PASSPORT: return preload(path + "passport.png")
		RumorImage.FLASK: return preload(path + "flask.png")
		RumorImage.PHOTO: return preload(path + "photo.png")
		#endregion mono
		
		_: printerr("NO SUCH IMAGE KEY IN RUMOR REGISTRY ", key)
	return null
