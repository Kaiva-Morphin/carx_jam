extends Interactible
class_name Ride


func hint() -> String:
	if GLOBAL.game_act == GLOBAL.GameAct.CanRide:
		return "KEY_CAN_RIDE"
	else:
		return "KEY_CANT_RIDE"

func interact() -> void:
	#if GLOBAL.game_act != GLOBAL.GameAct.CanRide: return
	GLOBAL.game_act = GLOBAL.GameAct.Lab
	GLOBAL.ui_state = GLOBAL.UI_STATE.ATOM
	GLOBAL.player.camera.current = false
	GLOBAL.block_player()
	$"../Atom".begin()
	GLOBAL.hints.rm_all()
