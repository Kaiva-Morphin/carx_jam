extends Area3D

var can_papa = false
var papa_shown = false
var shoot = false
func _process(_delta: float) -> void:
	if GLOBAL.ui_state != GLOBAL.UI_STATE.GAME: return
	if !can_papa: return
	if Input.is_action_just_pressed("show_papa"):
		if !shoot:
			# VOICEOVER.auto_next = true
			VOICEOVER.start_sequence("mono_compare")
			RUMOR.add_knowledge("missing_bottle")
		shoot = true
		papa_shown = true
		GLOBAL.processor.papa_in()
	if !Input.is_action_pressed("show_papa") && papa_shown:
		papa_shown = false
		GLOBAL.processor.papa_out()
		

func _on_body_entered(body: Node3D) -> void:
	if !body.is_in_group("player"): return
	can_papa = true
	GLOBAL.hints.hint("show_papa", "KEY_PAPA_LABEL")

func _on_body_exited(body: Node3D) -> void:
	if !body.is_in_group("player"): return
	if papa_shown:
		papa_shown = false
		GLOBAL.processor.papa_out()
	can_papa = false
	GLOBAL.hints.rm_hint("show_papa")
