extends Node3D

signal end


func _ready() -> void:
	VOICEOVER.sequence_end.connect(se)


func begin():
	GLOBAL.processor.black_in()
	await get_tree().create_timer(2.0).timeout
	$"../Room/Camera3D".current = true
	ride_dialog()


func ride_dialog():
	## VOICEOVER.auto_next = true
	VOICEOVER.start_sequence("second_ride")


func se(s):
	await get_tree().create_timer(0.02).timeout
	if s == "second_ride":
		$"../Room/Camera3D".current = true
		GLOBAL.processor.black_out()
		VOICEOVER.start_sequence("room1")
	if s == "room1":
		$AnimationPlayer.play("sit")
		VOICEOVER.start_sequence("room2")
	if s == "room2":
		GLOBAL.processor.black_in()
		end.emit()
