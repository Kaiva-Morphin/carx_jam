extends Area3D
class_name Interactible

signal interaction_start
signal interaction_end

@export var hint_keymap_ = "interact"
@export var hint_ = "KEY_INTERACTIBLE_DEFAULT"
@export var need_hint_ : bool = true
@export var knowledge : String = ""
@export var sequence : String = ""
@export var one_shoot = false

var _hint_node
func _ready() -> void:
	add_to_group("interactible")
	self.collision_layer = 4
	self.collision_mask = 4
	_hint_node = GLOBAL.visual_hint.instantiate()
	add_child(_hint_node)
	_hint_node.position.y = 0.0

func hint() -> String:
	if one_shoot && shooted: return ""
	return hint_

func hint_keymap() -> String:
	return hint_keymap_
var shooted = false
func interact() -> void:
	if one_shoot && shooted: return
	shooted = true
	if knowledge != "":
		RUMOR.add_knowledge(knowledge)
	if sequence != "":
		# VOICEOVER.auto_next = true
		VOICEOVER.start_sequence(sequence)
	if _hint_node:
		_hint_node.queue_free()
		_hint_node = null
	interaction_start.emit()
