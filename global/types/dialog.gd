extends Interactable
class_name CharacterDialog

@export var rotate_to_player : bool = false
@export var sequence_key = "test"
@onready var speaker = $Speaker
@onready var attention = $Attention
@onready var look_target = $Eyes


var player_in_range = false
var rotation_speed := 5.0
var last_target_angle = 0.0
func _process(dt: float) -> void:
	if !rotate_to_player: return
	if !player_in_range:
		speaker.rotation.y = lerp_angle(speaker.rotation.y, initial_rotation.y, rotation_speed * dt)
		return
	var target_dir = GLOBAL.player.global_position - speaker.global_position
	target_dir.y = 0
	var target_angle = atan2(target_dir.x, target_dir.z)
	speaker.rotation.y = lerp_angle(speaker.rotation.y, target_angle, rotation_speed * dt)
	


var initial_rotation := Vector3.ZERO
func _ready() -> void:
	add_to_group("interactible")
	super._ready()
	interaction_end.connect(GLOBAL.unblock_player)
	initial_rotation = speaker.rotation
	attention.area_entered.connect(_on_area_3d_area_entered)
	attention.area_exited.connect(_on_area_3d_area_exited)
	VOICEOVER.sequence_end.connect(on_end)

func interact() -> void:
	GLOBAL.ui_state = GLOBAL.UI_STATE.DIALOG
	VOICEOVER.start_sequence(sequence_key)
	GLOBAL.block_player()
	GLOBAL.processor.cinematic_in()
	GLOBAL.processor.player_look(look_target)

func on_end(k):
	if k != sequence_key: return
	GLOBAL.unblock_player()
	GLOBAL.ui_state = GLOBAL.UI_STATE.GAME
	GLOBAL.processor.cinematic_out()
	GLOBAL.processor.player_look(null)


func hint():
	return "E - Talk"

func _on_area_3d_area_entered(area: Area3D) -> void:
	if !area.is_in_group("player_attention"): return
	player_in_range = true

func _on_area_3d_area_exited(area: Area3D) -> void:
	if !area.is_in_group("player_attention"): return
	player_in_range = false
