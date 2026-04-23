extends Interactible
class_name Ride


var shoot = false
func hint() -> String:
	if shoot:
		return ""
	if can_ride():
		return "KEY_CAN_RIDE"
	else:
		return "KEY_CANT_RIDE"


var h = []
func _ready() -> void:
	super._ready()
	RUMOR.hearing_unlocked.connect(on_hearing)
	VOICEOVER.sequence_end.connect(er)

var need = [
	"BIO_1",
	"CIG",
	"BIO_3"
]


func on_hearing(k):
	if k in need:
		h.append(k)
		if can_ride():
			# VOICEOVER.auto_next = true
			VOICEOVER.push_sequence("ride")


func can_ride():
	for k in need:
		if !k in h: return false
	return true

func interact() -> void:
	if !can_ride(): return
	shoot = true
	super.interact()
	lab()
	#GLOBAL.game_act = GLOBAL.GameAct.Room
	#GLOBAL.ui_state = GLOBAL.UI_STATE.ROOM
	#GLOBAL.block_player()
	#$"../Room".begin()
	#GLOBAL.hints.rm_all()
	#$"../Room".end.connect(ride3)

func ride3():
	GLOBAL.ui_state = GLOBAL.UI_STATE.RIDE
	await get_tree().create_timer(1.5).timeout
	VOICEOVER.start_sequence("third_ride")

func er(e):
	if e == "third_ride":
		await get_tree().create_timer(1.5).timeout
		lab()
		return


func lab():
	GLOBAL.game_act = GLOBAL.GameAct.Lab
	GLOBAL.ui_state = GLOBAL.UI_STATE.ATOM
	GLOBAL.block_player()
	#GLOBAL.processor.black_out()
	$"../Atom".begin()
	GLOBAL.hints.rm_all()
