extends Node
class_name RumorManager

signal hearing_unlocked(key)
signal description_unlocked(hearing_key, index)
signal connection_unlocked(from_key, to_key)

var hearings_data = {}
var hearings_state = {}
var knowledge = {}

func _ready():
	_load_data()
	_init_state()

func _load_data():
	hearings_data = {
		"signal": {
			"title": "Strange Signal",
			"descriptions": [
				{ "text": "You detected a signal.", "cond": "found_signal" },
				{ "text": "It comes from Planet X.", "cond": "located_signal" }
			],
			"connections": [
				{ "to": "planet_x", "cond": "located_signal" }
			],
			"image_trigger": "located_signal",
			"image": "image.png",
			"position": Vector2(100, 200)
		},
		"planet_x": {
			"title": "Planet X",
			"descriptions": [
				{ "text": "A distant planet.", "cond": "visited_planet_x" }
			],
			"connections": [],
			"position": Vector2(400, 200)
		}
	}

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
			emit_signal("connection_unlocked", key, data.connections[i].to)

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
