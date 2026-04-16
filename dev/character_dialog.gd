extends Area3D

var initial_rotaion := Vector3.ZERO
@onready var person = $CharacterDialog/Person
@export var dialog = "test"
@export var key = "key"

signal end_interaction
var interaction_record

func interact():
	GLOBAL.dialog.show_dialog(DIALOGS.dialogs[dialog])
	GLOBAL.dialog.dialog_end.connect(end)

func end():
	GLOBAL.dialog.dialog_end.disconnect(end)
	end_interaction.emit()


func _ready() -> void:
	initial_rotaion = rotation
	interaction_record = {"type": GLOBAL.Interactable.Dialog, "node": self}

var player = false

var rotation_speed := 5.0
var last_target_angle = 0.0
func _process(dt: float) -> void:
	if !player:
		person.rotation.y = lerp_angle(person.rotation.y, initial_rotaion.y, rotation_speed * dt)
		return
	var target_dir = GLOBAL.player.global_position - person.global_position
	target_dir.y = 0
	var target_angle = atan2(target_dir.x, target_dir.z)
	person.rotation.y = lerp_angle(person.rotation.y, target_angle, rotation_speed * dt)



func _on_area_3d_area_entered(area: Area3D) -> void:
	if !area.is_in_group("player_interaction"): return
	player = true

func _on_area_3d_area_exited(area: Area3D) -> void:
	if !area.is_in_group("player_interaction"): return
	player = false
