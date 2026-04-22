extends Interactible
class_name Ride


func hint() -> String:
	if can_ride():
		return "KEY_CAN_RIDE"
	else:
		return "KEY_CANT_RIDE"

var h = []
func _ready() -> void:
	RUMOR.hearing_unlocked.connect(on_hearing)

var need = [
	"bio1",
	"cig",
	"bio3"
]

func on_hearing(k):
	if k in need: h.append(k)

func can_ride():
	for k in h:
		if !k in need: return false
	return true

func interact() -> void:
	if !can_ride(): return
	GLOBAL.game_act = GLOBAL.GameAct.Lab
	GLOBAL.ui_state = GLOBAL.UI_STATE.ATOM
	GLOBAL.player.camera.current = false
	GLOBAL.block_player()
	$"../Atom".begin()
	GLOBAL.hints.rm_all()
