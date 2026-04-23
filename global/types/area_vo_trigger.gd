extends Area3D
class_name AreaVoTrigger

@export var sequence : String = ""
@export var knowledge : String = ""

func _ready() -> void:
	if !self.visible: return
	self.body_entered.connect(on_enter)

var shoot = false
func on_enter(body):
	if !body.is_in_group("player"): return
	if shoot: return
	shoot = true
	if knowledge != "":
		RUMOR.add_knowledge(knowledge)
	if sequence != "":
		# VOICEOVER.auto_next = true
		VOICEOVER.start_sequence(sequence)
	else:
		printerr("areavotrigger empty seq")
